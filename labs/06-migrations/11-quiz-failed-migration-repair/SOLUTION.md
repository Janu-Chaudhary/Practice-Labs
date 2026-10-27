# Solution - 11 failed migration, repair

```bash
cd work
flyway info                     # 01 Success, 02 Failed
flyway migrate
# ERROR: Validate failed: Migrations have failed validation
# Detected failed migration to version 02 (add total paise).
# Please remove any half-completed changes then run repair to fix the schema history.
sqlite3 -header -column shop.db "SELECT version, script, success FROM flyway_schema_history;"   # 02 has success = 0
sqlite3 -header -column shop.db "SELECT * FROM orders;"      # total_paise exists AND is filled: steps 1+2 committed
sed -i 's/ON ordrs/ON orders/' migrations/02_add_total_paise.up.sql   # fix the typo (or edit it in VS Code / nano)
cat migrations/02_add_total_paise.up.sql                     # all 3 statements, index ON orders (total_paise)
sqlite3 shop.db "ALTER TABLE orders DROP COLUMN total_paise;"   # remove the half-completed change (derived data only)
flyway repair                   # deletes the Failed row from the history table (runs no migration SQL)
flyway info                     # 02 is Pending again
flyway migrate                  # 02 runs all three statements from the start, Success
flyway info                     # 01, 02 Success
sqlite3 -header -column shop.db "SELECT id, total, total_paise FROM orders;"   # 25000, 40000, 99900
flyway migrate                  # Schema "main" is up to date
```
You can also run 02's down file instead of the ALTER: `sqlite3 shop.db < migrations/02_add_total_paise.down.sql`
(it drops the index only `IF EXISTS`, so it works on the half-done state).

**Why each step**
- `flyway info` / `migrate` first: never guess. The validate message literally gives the order: *remove
  half-completed changes, then repair*.
- Look at the table: without a transaction, each statement autocommitted. Statement 1 (ADD COLUMN) and
  statement 2 (UPDATE) are in the database; statement 3 never happened. Flyway cannot undo them.
- Fixing the file is OK here: 02 never succeeded anywhere, so there is no good checksum to break.
  (After a Success, never edit: write the next migration - lab 07.)
- Drop the column by hand: when 02 re-runs from line 1, `ADD COLUMN total_paise` must not find it.
- `flyway repair`: removes Failed rows (and realigns checksums). It runs no migration SQL.
- On SQLite/PostgreSQL *with* a transaction (the default) none of this happens: the failure is rolled back
  and there is no history row. You only get a Failed row when the migration ran without a transaction.

**Common wrong attempts**
- `flyway repair` then `flyway migrate` without dropping the column -> `duplicate column name: total_paise`,
  and a NEW Failed row. Fix: drop the column, `flyway repair` again, migrate.
- Only fixing the typo and running migrate -> still "Detected failed migration to version 02": a Failed
  row blocks every migrate until repair.
- Deleting the Failed row with `DELETE FROM flyway_schema_history ...` -> works technically but the task
  says use the Flyway command; `repair` is the tool that knows the table's rules.
- Removing the ALTER/UPDATE lines from 02 so it "only does the index" -> this database works, but a fresh
  database (CI, a teammate) never gets `total_paise`. A migration must take ANY database from 01 to 02.
- Deleting `shop.db` and migrating from zero -> the 3 orders are gone.
