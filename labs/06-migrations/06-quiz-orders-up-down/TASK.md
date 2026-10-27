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
migration. Flyway (free edition) never runs `.down.sql` files: you only write them, so the change can be
undone later.

**Task:** write 2 migrations and 2 reverse migrations in `migrations/`, and apply them with flyway:
- `03_add_currency.up.sql`: add a column `currency` of type `TEXT` to `orders` that is **NOT NULL**
  with default `'INR'` (so the 3 existing orders get `INR`).
- `03_add_currency.down.sql`: reverse it (remove the column).
- `04_create_coupons.up.sql`: create table `coupons` with `code TEXT PRIMARY KEY` and `percent INTEGER NOT NULL`.
- `04_create_coupons.down.sql`: reverse it.
- Apply 03 and 04 with `flyway migrate`.

**Stop:** don't edit 01/02, don't delete rows, don't delete `shop.db`.

**Hints**
- Create each file in the Files panel: **+ New file**, type the path (e.g. `migrations/03_add_currency.up.sql`),
  write the SQL, save with **Ctrl+S**. One statement per file is enough here; end it with `;`.
- `flyway info` before and after. A file that does not show up in `info` is misnamed (down files never show up).
- SQLite needs a DEFAULT when you add a NOT NULL column to a table that has rows.
- A down file undoes **only its own** migration. Undo order is newest first: 04's down, then 03's down.

**What will be checked**
- the 4 files exist; 01/02 unchanged (`flyway validate` passes)
- history rows for 03 and 04 (exact script names), 4 successful rows in total
- orders: 3 rows, `currency` NOT NULL, `INR` everywhere; `coupons(code, percent)` exists
- the checker runs 04.down then 03.down on a **copy** of `shop.db`: coupons and currency are gone, 3 rows kept
