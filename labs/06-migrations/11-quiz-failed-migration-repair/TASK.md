# 11 - A migration failed halfway: clean up, repair, migrate (Quiz-style)

**Situation.** Course naming (`NN_name.up.sql` / `.down.sql`). `shop.db` has 01 applied and 3 orders.
A teammate wrote `02_add_total_paise.up.sql`, a three-step **backfill** migration:
add a column `total_paise`, fill it with `total * 100`, then index it.
02 has a script config file `02_add_total_paise.up.sql.conf` with `executeInTransaction=false`
(the team wanted to see how Flyway behaves on a database like MySQL, where DDL can't be rolled back).

The deploy ran `flyway migrate` and it **failed on the last statement** (a typo). Because there was no
transaction, the first two statements stayed committed, and Flyway wrote a **Failed** row into the history table.

**Task** (inside `work/`):
1. `flyway info`: what state is 02 in? `flyway migrate`: read the validate error (it tells you the plan).
2. Find out exactly what the failed run left behind: look at the `orders` table (columns and rows) and the
   history table with sqlite3.
3. Fix the typo in `02_add_total_paise.up.sql`. (Allowed: 02 never succeeded anywhere, so no database
   has a good checksum for it yet.)
4. Remove the half-completed change by hand, clear the failed row the Flyway way, then `flyway migrate`
   so 02 runs **completely** from the start.
5. `flyway info` shows 01 and 02 Success; `flyway migrate` again says up to date.

**Stop:** don't delete `shop.db` or any orders; don't edit 01; don't delete the `.conf` file or remove
statements from 02 (other databases still need all three steps); don't delete history rows with SQL
(use the Flyway command that does it).

**Hints**
- `sqlite3 -header -column shop.db "SELECT * FROM flyway_schema_history;"` - look at the `success` column.
- `sqlite3 -header -column shop.db "SELECT * FROM orders;"` - is there already a `total_paise` column? Is it filled?
- `total_paise` only holds data copied from `total`, so dropping it loses nothing. 02's down file shows how.
- Which order? If you clear the failed row but forget the half-completed change, the next migrate fails
  again (on a different statement) and writes a NEW failed row.

**What will be checked**
- 02 still has all three steps and the index now targets `orders`; 01 and the `.conf` file unchanged
- history: no failed rows, exactly one 02 row and it is Success; `flyway validate` passes
- orders keeps 3 rows with `total_paise = total * 100`; the column exists once; the index is on `orders`
