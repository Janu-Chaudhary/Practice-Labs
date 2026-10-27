# Solution - 08 hand-run SQL

```bash
cd work
flyway info          # 03 Pending, 04 Pending - the hand-run ALTER changed the schema but wrote NO history row
flyway migrate
# ERROR: Migration of schema "main" to version "03 - add full name" failed! Changes successfully rolled back.
# Message    : [SQLITE_ERROR] SQL error or missing database (duplicate column name: full_name)
cat NOTE.txt                               # ALTER TABLE users ADD COLUMN full_name text;
cat migrations/03_add_full_name.up.sql     # ALTER TABLE users ADD COLUMN full_name text;   -> identical
flyway migrate -skipExecutingMigrations=true -target=03   # writes the history row for 03, runs no SQL
flyway info          # 03 Success, 04 Pending
flyway migrate       # runs 04 for real: Migrating schema "main" to version "04 - add phone"
flyway info          # 01-04 Success, Schema version: 04
flyway migrate       # Schema "main" is up to date. No migration necessary.
```

**Why it failed** (Q8 answer B): running SQL by hand changes the schema but adds no row to the history
table, so the runner still sees 03 as pending and runs `ADD COLUMN` on a column that already exists.
On PostgreSQL the message is `column "full_name" of relation "users" already exists`; SQLite says
`duplicate column name: full_name`. For a hand-made table: `table x already exists`.
Not a checksum problem (file unchanged), and the runner does not "always run every file".

"Changes successfully rolled back": Flyway wraps each migration in BEGIN ... COMMIT, so a failed
migration leaves no half-done change and no history row. 04 never started: Flyway stops at the first failure.

**Why `-skipExecutingMigrations=true`:** the database already has exactly what 03 would do. You only need
Flyway to write the history row (with the right checksum). Writing that row by hand would mean faking a checksum.

**Why `-target=03`:** without it, Flyway would also *record* 04 without running it. Then `flyway info` says
04 Success, but the `phone` column does not exist: the history table lies.

**Why compare with the note first:** if Ravi had typed something different (e.g. `full_name TEXT NOT NULL DEFAULT ''`),
recording 03 as applied would hide that difference. Then the database differs from every fresh one.

**Common wrong attempts**
- `flyway migrate -skipExecutingMigrations=true` with no target -> 04 is recorded but never ran; `phone`
  is missing (check fails). `./setup.sh` and redo.
- Deleting/renaming the 03 file so migrate passes -> other databases never get full_name.
- `flyway repair` -> does nothing here (no failed row is stored, checksum fine).
- `flyway baseline -baselineVersion=03` -> refused: the history table already exists.
- Editing 03 to something "safe" -> it is shared with every other database; leave it as it is.
