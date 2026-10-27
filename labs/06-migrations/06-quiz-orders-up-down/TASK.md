# 06 - Write migrations + reverse migrations and apply them with Flyway (Quiz-style, Quiz 2 Q18)

The real Q18 text was cut off in the PDF after "apply them with flyway:". This is a faithful
reconstruction: same files, same database, same kind of task.

```
migrations/01_create_orders.up.sql
  CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);
migrations/02_index_orders.up.sql
  CREATE INDEX idx_orders_user ON orders (user_id);
```
**Context:** `shop.db` has migrations 01 and 02 applied, and the orders table has 3 rows.
`flyway.toml` is set up for this naming: `NN_name.up.sql` = migration, `NN_name.down.sql` = reverse
migration (Flyway ignores `.down.sql`; you would run it by hand).

**Task:** write 2 migrations and 2 reverse migrations in `migrations/`, and apply them with flyway:
- `03_add_currency.up.sql`: add a column `currency` of type `TEXT` to `orders` that is **NOT NULL**
  with default `'INR'` (so the 3 existing orders get `INR`).
- `03_add_currency.down.sql`: reverse it (remove the column).
- `04_create_coupons.up.sql`: create table `coupons` with `code TEXT PRIMARY KEY` and `percent INTEGER NOT NULL`.
- `04_create_coupons.down.sql`: reverse it.
- Apply 03 and 04 with `flyway migrate`. Don't run the down files on `shop.db`.

**Stop:** don't edit 01/02, don't delete rows, don't delete `shop.db`.

**Hints**
- `flyway info` before and after. A file that does not show up in `info` is misnamed.
- SQLite needs a DEFAULT when you add a NOT NULL column to a table that has rows.
- Test your down files on a **copy**: `cp shop.db /tmp/t.db; sqlite3 /tmp/t.db < migrations/04_...down.sql`.
  Reverse order matters: undo 04 first, then 03.

**What will be checked**
- the 4 files exist; 01/02 unchanged (`flyway validate` passes)
- history rows for 03 and 04 (exact script names), 4 successful rows in total
- orders: 3 rows, `currency` NOT NULL, `INR` everywhere; `coupons(code, percent)` exists
- running 04.down then 03.down on a copy removes coupons and currency and keeps the 3 rows
