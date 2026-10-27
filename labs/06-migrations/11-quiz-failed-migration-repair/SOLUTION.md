# Solution - 11 failed migration, repair

```bash
cd work
flyway info                     # 01 Success, 02 Failed
flyway migrate
# ERROR: Validate failed: Migrations have failed validation
# Detected failed migration to version 02 (create coupons).
# Please remove any half-completed changes then run repair to fix the schema history.
cat migrations/02_create_coupons.up.sql   # last line: ... ON coupns (percent);  <- typo
```
Open `migrations/02_create_coupons.up.sql` in the Files panel and change it to:
```sql
-- coupons table, two starter coupons, and an index for "find coupons by percent"
CREATE TABLE IF NOT EXISTS coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);
INSERT OR IGNORE INTO coupons (code, percent) VALUES ('WELCOME10', 10), ('FESTIVE20', 20);
CREATE INDEX IF NOT EXISTS idx_coupons_percent ON coupons (percent);
```
Save with **Ctrl+S**.
```bash
flyway repair                   # deletes the Failed row from the history table (runs no migration SQL)
flyway info                     # 02 is Pending again
flyway migrate                  # 02 runs from line 1: table and rows are skipped, the index is created. Success
flyway info                     # 01, 02 Success
flyway migrate                  # Schema "main" is up to date
```

**Why each step**
- `flyway info` / `migrate` first: never guess. The validate message gives the plan: *remove
  half-completed changes, then repair*.
- What was left behind: without a transaction, each statement autocommitted. Statement 1 (CREATE TABLE)
  and statement 2 (INSERT) are in the database; statement 3 never happened. Flyway cannot undo them.
- Making 02 re-runnable *is* how you deal with the half-completed change through Flyway: on this database
  the first two statements now do nothing, on a fresh database they do everything. Every database ends
  in the same state. (PostgreSQL has the same idea: `IF NOT EXISTS`, `INSERT ... ON CONFLICT DO NOTHING`.)
- Fixing the file is OK here: 02 never succeeded anywhere, so there is no good checksum to break.
  (After a Success, never edit: write the next migration - lab 07.)
- `flyway repair`: removes Failed rows (and realigns checksums). It runs no migration SQL.
- On SQLite/PostgreSQL *with* a transaction (the default) none of this happens: the failure is rolled back
  and there is no history row. You only get a Failed row when the migration ran without a transaction.

**Common wrong attempts**
- Only fixing the typo, then `flyway repair` + `flyway migrate` ->
  `[non-transactional] failed! ... (table coupons already exists)` and a NEW Failed row.
  Fix: make the statements re-runnable, `flyway repair` again, migrate.
- `IF NOT EXISTS` on the table but a plain `INSERT` -> `UNIQUE constraint failed: coupons.code`
  (the two coupons are already there), another Failed row.
- Only fixing the typo and running migrate -> still "Detected failed migration to version 02": a Failed
  row blocks every migrate until repair.
- Removing the CREATE/INSERT lines from 02 so it "only does the index" -> this database works, but a fresh
  database (CI, a teammate) never gets the coupons table. A migration must take ANY database from 01 to 02.
- Deleting `shop.db` and migrating from zero -> the 3 orders are gone.
