# Solution - 02 first migrate

```bash
cd work
flyway info          # V1 Pending: file exists, no history row yet (shop.db doesn't even exist)
flyway migrate       # creates shop.db + flyway_schema_history, runs V1, inserts history row for 1
flyway info          # V1 Success, with an "Installed On" time = its history row
```
In the Files panel click **+ New file**, type `migrations/V2__add_email.sql`, write:
```sql
ALTER TABLE users ADD COLUMN email TEXT;
```
Save with **Ctrl+S**. The next change is always a **new** file.
```bash
flyway info          # V1 Success, V2 Pending
flyway migrate       # only V2 runs: V1 already has a history row
flyway info          # both Success
flyway migrate       # Schema "main" is up to date. No migration necessary.
```

**What you should notice**
- `migrate` output: `Migrating schema "main" to version "2 - add email"` then `Successfully applied 1 migration`.
- The file name becomes the history row: version `2`, description `add email` (underscores -> spaces).
- Running migrate again is safe: no pending file -> nothing to do.

**Common wrong attempts**
- `V2_add_email.sql` (one underscore) -> `ERROR: Invalid SQL filenames found` (because `validateMigrationNaming = true`; without it Flyway silently ignores the file!).
- `v2__add_email.sql` (lower-case v) -> same error, prefix is case-sensitive.
- Creating `V2__add_email.sql` outside `migrations/` (typing only the file name in **+ New file**) ->
  Flyway only looks in `migrations/`, so info does not list it.
- Forgetting Ctrl+S -> Flyway reads the file on disk, not your editor tab. If V2 ran empty, `email`
  never appears, and fixing the file afterwards gives a checksum mismatch. Save first, then migrate.
- Putting the ALTER into V1 instead of a new file -> V1 already applied, so `flyway migrate` fails with *checksum mismatch* (lab 07).
- Running `flyway` outside `work/` -> it can't find `flyway.toml` / `migrations` (wrapper warns).
