# Solution - 01 flyway info basics

```bash
cd work
ls migrations         # 01..04, each with .up.sql and .down.sql
flyway info
# Schema version: 02
# | Versioned | 01 | create users   | SQL | 2026-10-27 17:30:01 | Success | No |
# | Versioned | 02 | create orders  | SQL | 2026-10-27 17:30:01 | Success | No |
# | Versioned | 03 | add city       | SQL |                     | Pending | No |
# | Versioned | 04 | create coupons | SQL |                     | Pending | No |
```
In the Files panel click **+ New file**, type `answer.txt`, write:
```
02
2
```
Save with **Ctrl+S**.
```bash
flyway migrate -target=03   # runs 03 only: Successfully applied 1 migration ... now at version v03
flyway info                 # Schema version: 03. 01-03 Success, 04 still Pending
```

**Why each step**
- `flyway info` is read-only. It puts two lists side by side: the files in `migrations/` and the rows in
  the history table. A file with a row is **Success**; a file with no row yet is **Pending**.
- "Schema version" = the highest version that is applied. Pending files don't count.
- `Installed On` is empty for Pending rows: they never ran here.
- `-target=03` = "migrate, but stop at 03". Without it, `flyway migrate` runs every pending file (03 and 04).
- Only `.up.sql` files are listed: `flyway.toml` says `sqlMigrationSuffixes = [".up.sql"]`.

**Common wrong attempts**
- `flyway migrate` with no target -> 04 is applied too. The free edition has no undo, so
  `./setup.sh` and try again.
- `flyway -target=03` (no command) -> Flyway prints its help: the command is missing.
- Line 2 = `4` -> you counted all rows. Only rows whose State is `Pending` count.
- Line 1 = `03` -> that is the version *after* your migrate. The question is what info said before.
- Running `flyway` outside `work/` -> it can't find `flyway.toml` (the wrapper warns).
