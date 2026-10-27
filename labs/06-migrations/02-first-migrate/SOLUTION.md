# Solution - 02 first migrate

```bash
cd work
flyway info          # V1 Pending: file exists, no history row yet (shop.db doesn't even exist)
flyway migrate       # creates shop.db + flyway_schema_history, runs V1, inserts history row for 1
sqlite3 -header -column shop.db "SELECT installed_rank, version, description, script, checksum, success FROM flyway_schema_history;"
echo 'ALTER TABLE users ADD COLUMN email TEXT;' > migrations/V2__add_email.sql   # the next change = a NEW file
flyway migrate       # only V2 runs: V1 already has a history row
flyway info          # both Success
flyway migrate       # Schema "main" is up to date. No migration necessary.
sqlite3 shop.db ".schema users"   # email is there
```

**What you should notice**
- `migrate` output: `Migrating schema "main" to version "2 - add email"` then `Successfully applied 1 migration`.
- The file name becomes the history row: version `2`, description `add email` (underscores -> spaces).
- Running migrate again is safe: no pending file -> nothing to do.

**Common wrong attempts**
- `V2_add_email.sql` (one underscore) -> `ERROR: Invalid SQL filenames found` (because `validateMigrationNaming = true`; without it Flyway silently ignores the file!).
- `v2__add_email.sql` (lower-case v) -> same error, prefix is case-sensitive.
- Putting the ALTER into V1 instead of a new file -> V1 already applied, so `flyway migrate` fails with *checksum mismatch* (lab 07).
- Running `flyway` outside `work/` -> it can't find `flyway.toml` / `migrations` (wrapper warns).
