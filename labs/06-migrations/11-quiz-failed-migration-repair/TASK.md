# 11 - A migration failed halfway: make it re-runnable, repair, migrate (Quiz-style)

**Situation.** Course naming (`NN_name.up.sql` / `.down.sql`). `shop.db` has 01 applied and 3 orders.
A teammate wrote `02_create_coupons.up.sql`, a three-step migration:
create the `coupons` table, insert two starter coupons, then index it.
02 has a script config file `02_create_coupons.up.sql.conf` with `executeInTransaction=false`
(the team wanted to see how Flyway behaves on a database like MySQL, where DDL can't be rolled back).

The deploy ran `flyway migrate` and it **failed on the last statement** (a typo). Because there was no
transaction, the first two statements stayed committed: the table and its 2 rows are in `shop.db`.
Flyway wrote a **Failed** row into the history table.

**Task** (inside `work/`):
1. `flyway info`: what state is 02 in? `flyway migrate`: read the validate error (it tells you the plan).
2. Open `migrations/02_create_coupons.up.sql` in the Files panel and find the typo.
3. Think before you fix: when 02 runs again, it starts from line 1. But the table and the 2 coupons
   already exist. You may only change the database **through Flyway**, so make 02 **safe to re-run**:
   every statement must work whether or not its part was already done. Fix the typo too.
   Save with **Ctrl+S**. (Editing 02 is allowed: it never succeeded anywhere, so no database has a good
   checksum for it yet.)
4. Clear the Failed row the Flyway way, then `flyway migrate` so 02 completes.
5. `flyway info` shows 01 and 02 Success; `flyway migrate` again says up to date.

**Stop:** don't delete `shop.db` or any orders; don't edit 01; don't delete the `.conf` file or remove
statements from 02 (a fresh database still needs all three steps); don't change the database outside Flyway.

**Hints**
- SQLite has "skip if it is already there" forms: `CREATE TABLE IF NOT EXISTS ...`,
  `INSERT OR IGNORE INTO ...` (skips rows whose PRIMARY KEY exists), `CREATE INDEX IF NOT EXISTS ...`.
- Which order? If you clear the failed row but 02 is not re-runnable, the next migrate fails again
  (`table coupons already exists`) and writes a NEW Failed row. Just fix 02 and repair again.

**What will be checked**
- 02 still has all three steps and the index now targets `coupons`; 01 and the `.conf` file unchanged
- history: no failed rows, exactly one 02 row and it is Success; `flyway validate` passes
- coupons has exactly the 2 coupons (no duplicates) and the index; orders keeps 3 rows
- the checker migrates a brand-new empty database with your files: it must get coupons too
