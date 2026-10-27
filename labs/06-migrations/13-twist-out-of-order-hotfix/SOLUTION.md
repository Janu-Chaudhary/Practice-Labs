# Solution - 13 out-of-order hotfix vs renumber

```bash
cd work
flyway info                     # 202610221500 and 202610231000: State "Ignored"
echo Ignored > answer.txt
flyway migrate
# ERROR: Validate failed: Migrations have failed validation
# Detected resolved migration not applied to database: 202610221500.
# To ignore this migration, set -ignoreMigrationPatterns='*:ignored'. To allow executing this migration, set -outOfOrder=true.
# Detected resolved migration not applied to database: 202610231000. ...
git status --short              # ?? the two 202610231000 files: untracked (never committed)
mv migrations/202610231000_add_order_notes.up.sql   migrations/202610271100_add_order_notes.up.sql
mv migrations/202610231000_add_order_notes.down.sql migrations/202610271100_add_order_notes.down.sql
git add migrations
git commit -m "Add order notes migration (timestamp 202610271100)"
flyway info                     # 202610221500 Ignored, 202610271100 Pending
flyway migrate -outOfOrder=true # applies 202610221500 (out of order) and then 202610271100
flyway info                     # 202610221500 "Out of Order", the rest Success
sqlite3 -header -column shop.db "SELECT installed_rank, version, script FROM flyway_schema_history ORDER BY installed_rank;"
#  1 202610201000, 2 202610251200, 3 202610221500, 4 202610271100
flyway migrate                  # up to date (no flag needed any more)
git status                      # only answer.txt untracked
```

**Why each step**
- "Ignored" = Flyway sees the file, but its version is lower than the current version, so by default it
  will not run it, and `validate` (inside migrate) fails so you notice.
- The hotfix keeps 202610221500: production's history table has a row with that version and checksum.
  Renaming it would make production see a "new" migration and run the ALTER again (`duplicate column`),
  and production would report version 202610221500 as missing locally.
- Your notes file ran nowhere, so changing its version is free. The newest timestamp makes it a normal,
  in-order migration everywhere. That is better than outOfOrder: every database runs it in the same order.
- `-outOfOrder=true` on the command line allows lower versions for this run only. Once applied, the
  history row exists and plain `migrate`/`validate` are happy again.
- Rename BEFORE migrating: `-outOfOrder=true` would also run 202610231000, and then that version is
  in your history forever.

**Common wrong attempts**
- `git mv migrations/202610231000_... ...` -> `fatal: not under version control`: the file is untracked.
- Running `flyway migrate -outOfOrder=true` first -> 202610231000 gets applied with the old version.
  Fix: `./setup.sh` and do it in the right order.
- Renaming the teammate's hotfix to a new timestamp -> your DB works, but production would run it twice.
- Putting `outOfOrder = true` in flyway.toml -> now every future late migration slips in silently.
- `-ignoreMigrationPatterns='*:ignored'` -> migrate "succeeds" but skips both files: nothing is applied.
- `git commit -am ...` without `git add` -> untracked new files are not included (tree not clean).
