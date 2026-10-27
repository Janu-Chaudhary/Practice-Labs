# Solution - 14 history detective

```bash
cd work
ls migrations                                 # 01..05, each .up.sql + .down.sql
flyway info
# Schema version: 05
# | Versioned | 01 | create users    | SQL      |                     | Ignored (Baseline) |
# |           | 01 | existing schema | BASELINE | 2026-10-27 17:24:07 | Baseline           |
# | Versioned | 02 | create orders   | SQL      | 2026-10-27 17:24:17 | Success            |
# | Versioned | 03 | add city        | SQL      | 2026-10-27 17:24:17 | Success            |
# | Versioned | 05 | create coupons  | SQL      | 2026-10-27 17:24:17 | Success            |
# | Versioned | 04 | index orders    | SQL      | 2026-10-27 17:24:26 | Out of Order       |   <- ran last
```
Part A: create four files in the Files panel (**+ New file**, write the one answer, **Ctrl+S**):

| File | Content | Where you read it |
|------|---------|-------------------|
| `q1.txt` | `04` | last row of the table, latest `Installed On` |
| `q2.txt` | `05` | `Schema version: 05` above the table |
| `q3.txt` | `Out of Order` | State of 04 |
| `q4.txt` | `01` | the 01 file is `Ignored (Baseline)`; a BASELINE row stands in for it |

```bash
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
git status --short                            # only the q*.txt files, untracked
```

**Why each step**
- `flyway info` shows applied rows in the order Flyway *ran* them (`installed_rank` in the history table),
  but the schema version is the highest version applied. They differ when something ran out of order:
  04 ran last, but the schema version is 05.
- "Out of Order" = 04 was applied after a higher version (05) was already there, with `-outOfOrder=true`.
- 01 has a file, but the BASELINE row says "everything up to 01 was already there". Flyway never ran
  01's SQL on this DB (info: `Ignored (Baseline)`). On a fresh DB it would run.
- The checksum is a number Flyway computes from the file's **whole text**, comments included. That is why a
  comment-only edit breaks validate.
- `flyway repair` is right **here**: the edit does not change what the SQL does, so every database that ran
  the old 03 is still correct. Repair just records the new checksum. Compare lab 07: there the edit added a
  column, so repair would hide a real difference - the change belonged in a new migration.

**Common wrong attempts**
- q1 = 05 (the highest version, not the last one run). q2 = 04 (last run, not the schema version).
- q3 = `Success` -> that is 05's state; 04 has its own state name.
- q4 = 02 or "none" -> look for the row that is *Ignored (Baseline)*: a file, but no SQL row.
- `git revert HEAD` / `git restore` 03 -> validate passes, but the team's comment is gone and a commit is
  added (task says keep it).
- `flyway migrate` hoping it fixes things -> it runs validate first and stops with the same mismatch.
