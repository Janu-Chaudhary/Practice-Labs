# Solution - 14 history detective

```bash
cd work
sqlite3 -header -column shop.db "SELECT installed_rank, version, type, script, checksum, success FROM flyway_schema_history ORDER BY installed_rank;"
# 1 01 BASELINE  existing schema
# 2 02 SQL       02_create_orders.up.sql
# 3 03 SQL       03_add_city.up.sql      <checksum>
# 4 05 SQL       05_create_coupons.up.sql
# 5 04 SQL       04_index_orders.up.sql   <- ran last, out of order
flyway info                                   # "Schema version: 05", 04 "Out of Order", 01 file "Ignored (Baseline)"
# Part A
sqlite3 shop.db "SELECT version FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 1;" > q1.txt   # 04
sqlite3 shop.db "SELECT max(version) FROM flyway_schema_history WHERE success = 1;" > q2.txt                 # 05
sqlite3 shop.db "SELECT checksum FROM flyway_schema_history WHERE version = '03';" > q3.txt                  # the OLD checksum
sqlite3 shop.db "SELECT version FROM flyway_schema_history WHERE type = 'BASELINE';" > q4.txt               # 01
cat q1.txt q2.txt q3.txt q4.txt
# Part B
flyway validate
# Migration checksum mismatch for migration version 03
# -> Applied to database : 1676901193
# -> Resolved locally    : 1815191245
git log --oneline                             # "Document why city is nullable" on top
git diff HEAD~1 HEAD                          # only a "-- city is nullable ..." line was added
flyway repair                                 # stores the new checksum for 03; runs no migration SQL
flyway validate                               # Successfully validated
flyway migrate                                # Schema "main" is up to date
sqlite3 shop.db "SELECT checksum FROM flyway_schema_history WHERE version = '03';"   # new value, != q3.txt
```
(`max(version)` works here because all versions have the same width, `01`..`05`, so text order = number
order. Reading "Schema version: 05" off `flyway info` and `echo 05 > q2.txt` is just as good.)

**Why each step**
- `installed_rank` is the order Flyway *ran* things; `version` is the order it *wants* them in. They differ
  when something ran out of order: 04 ran last, but the schema version is the highest applied: 05.
- The checksum is a number Flyway computes from the file's **whole text**, comments included. That is why a
  comment-only edit breaks validate.
- 01 has a file, but the BASELINE row says "everything up to 01 was already there". Flyway never ran
  01's SQL on this DB (info: `Ignored (Baseline)`). On a fresh DB it would run.
- `flyway repair` is right **here**: the edit does not change what the SQL does, so every database that ran
  the old 03 is still correct. Repair just records the new checksum. Compare lab 07: there the edit added a
  column, so repair would hide a real difference - the change belonged in a new migration.

**Common wrong attempts**
- q1 = 05 (the highest version, not the last one run). q2 = 04 (last run, not the schema version).
- Running `flyway repair` before writing q3 -> the stored checksum is already the new one; q3 is wrong.
  (`./setup.sh` resets.)
- `WHERE version = 3` (number) -> no row: version is TEXT `'03'`.
- `git revert HEAD` / `git restore` 03 -> validate passes, but the team's comment is gone and a commit is
  added (task says keep it).
- `UPDATE flyway_schema_history SET checksum = ...` by hand -> you'd have to know Flyway's checksum; use repair.
- Answer files with headers (`sqlite3 -header ... > q1.txt`) -> "version\n04" is not a single value.
