# Solution - 09 expand / contract

```bash
cd work
# 1 Expand
echo "ALTER TABLE users ADD COLUMN full_name text;" > migrations/02_add_full_name.up.sql
echo "ALTER TABLE users DROP COLUMN full_name;"     > migrations/02_add_full_name.down.sql
flyway migrate -target=02                 # only 02 runs
sqlite3 -header -column shop.db "SELECT * FROM users;"     # full_name NULL x3, old code unaffected
# 2 Backfill (a data change, safe to re-run because of WHERE ... IS NULL)
echo "UPDATE users SET full_name = user_name WHERE full_name IS NULL;" > migrations/03_backfill_full_name.up.sql
flyway migrate -target=03
sqlite3 shop.db "SELECT count(*) FROM users WHERE full_name IS NULL;"   # 0
# 3 Transition = app change, no SQL
# 4 Contract
echo "ALTER TABLE users DROP COLUMN user_name;" > migrations/04_drop_user_name.up.sql
cat > migrations/04_drop_user_name.down.sql <<'SQL'
ALTER TABLE users ADD COLUMN user_name text;
UPDATE users SET user_name = full_name;
SQL
flyway migrate                            # runs 04
flyway info                               # 01-04 Success
sqlite3 shop.db ".schema users"
```

**Why staged?** Each step must be live everywhere before the next starts: old instances still read
`user_name` until the transition deploy is done, so the drop (contract) can only ship last.
In real life each `migrate` would be a separate deploy, days apart. `-target` lets you stop at a version.

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
