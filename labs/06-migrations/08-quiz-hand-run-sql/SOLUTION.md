# Solution - 08 hand-run SQL

```bash
cd work
flyway info          # 03 Pending - the hand-run ALTER changed the schema but wrote NO history row
flyway migrate
# ERROR: Migration of schema "main" to version "03 - add full name" failed! Changes successfully rolled back.
# Message    : [SQLITE_ERROR] SQL error or missing database (duplicate column name: full_name)
sqlite3 shop.db "SELECT count(*) FROM users WHERE full_name IS NOT NULL;"   # 0 -> nothing to lose
sqlite3 shop.db "ALTER TABLE users DROP COLUMN full_name;"                  # undo the hand change
flyway migrate       # now Flyway runs 03 itself AND records it
flyway info          # 03 Success
```
**Option B** (no schema change, just record it): the column made by hand is identical to what 03 does, so
```bash
flyway migrate -skipExecutingMigrations=true -target=03   # writes the history row, skips the SQL
```
`-target=03` matters: without it, *every* pending migration would be marked applied without running.

**Why it failed** (Q8 answer B): running SQL by hand changes the schema but adds no row to the history
table, so the runner still sees 03 as pending and runs `ADD COLUMN` on a column that already exists.
On PostgreSQL the message is `column "full_name" of relation "users" already exists`; SQLite says
`duplicate column name: full_name`. For a hand-made table: `table x already exists`.
Not a checksum problem (file unchanged), and the runner does not "always run every file".

"Changes successfully rolled back": Flyway wraps each migration in BEGIN ... COMMIT, so a failed
migration leaves no half-done change and no history row.

**Common wrong attempts**
- Deleting/renaming the 03 file so migrate passes -> other databases never get full_name.
- `flyway repair` -> does nothing here (no failed row is stored, checksum fine).
- `flyway baseline -baselineVersion=03` -> refused: the history table already exists.
- `-skipExecutingMigrations=true` without `-target` when more files are pending -> marks all of them applied.
