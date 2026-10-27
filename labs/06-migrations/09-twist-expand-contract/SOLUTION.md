# Solution - 09 expand / contract

All files are made in the Files panel: **+ New file**, type the path, write the SQL, save with **Ctrl+S**.

**1 Expand.** `migrations/02_add_full_name.up.sql`
```sql
ALTER TABLE users ADD COLUMN full_name text;
```
`migrations/02_add_full_name.down.sql`
```sql
ALTER TABLE users DROP COLUMN full_name;
```
```bash
cd work
flyway migrate -target=02                 # only 02 runs
flyway info                               # 02 Success, Schema version: 02. Old code is unaffected
```

**2 Backfill** (a data change, safe to re-run because of `WHERE ... IS NULL`). `migrations/03_backfill_full_name.up.sql`
```sql
UPDATE users SET full_name = user_name WHERE full_name IS NULL;
```
```bash
flyway migrate -target=03                 # only 03 runs
flyway info                               # 03 Success
```

**3 Transition** = app change (reads full_name, still writes both). No SQL.

**4 Contract.** `migrations/04_drop_user_name.up.sql`
```sql
ALTER TABLE users DROP COLUMN user_name;
```
`migrations/04_drop_user_name.down.sql` (two statements, each ends with `;`)
```sql
ALTER TABLE users ADD COLUMN user_name text;
UPDATE users SET user_name = full_name;
```
```bash
flyway migrate                            # runs 04
flyway info                               # 01-04 Success, Schema version: 04
flyway validate                           # Successfully validated 4 migrations
```

**Why staged?** Each step must be live everywhere before the next starts: old instances still read
`user_name` until the transition deploy is done, so the drop (contract) can only ship last.
In real life each `migrate` would be a separate deploy, days apart. `-target` lets you stop at a version.
If you write 04 before migrating 02, a plain `flyway migrate` would run 02, 03 and 04 at once: that is
the big-bang rename again. Write each stage's files, migrate, then go on.

**Why the down for 04 copies data:** `ADD COLUMN user_name text` alone gives NULL in every row
(the slide "Down only" vs "Deliberate repair"). It works here only because `full_name` still has the
names; if values exist nowhere else, no reverse migration can invent them.

The lecture puts the backfill in a job, not a migration (so it has no history row). Putting it in 03 is
fine for small tables; on big ones run it in batches (`WHERE id IN (SELECT id ... LIMIT 1000)`).

**Common wrong attempts**
- One migration `ALTER TABLE users RENAME COLUMN user_name TO full_name;` -> old instances get
  `no such column: user_name`. That is answer C in Q11.
- Backfill before expand / reading before backfill -> NULL names in the new code (Q11 option B/D).
- 04.down with only `ADD COLUMN` -> check "user_name = full_name" fails (NULLs).
- Putting `NOT NULL` on the new column in 02 without a default -> SQLite: `Cannot add a NOT NULL column with default value NULL`.
- `flyway migrate -target 02` (space instead of `=`) -> `ERROR: Invalid flag: -target`. Use `-target=02`.
