# 12 - Versioned vs repeatable migrations: change a view (Quiz-style)

**Situation.** This lab uses **Flyway's default naming**, which has two kinds of migration:
- **Versioned** `V<version>__<description>.sql`: runs **once**, in version order. Never edit after it ran.
- **Repeatable** `R__<description>.sql`: has **no version**. Flyway runs it after all versioned ones, and
  runs it **again every time its checksum changes** (i.e. you edited the file). Good for views, which
  you simply drop and re-create. So for a repeatable migration, editing the file IS the way to change it.

`shop.db` has V1 (users, with an `active` flag), V2 (orders) and `R__active_users.sql` (a view) applied.
3 users (Ravi is inactive) and 3 orders.

**Task** (inside `work/`), finish with **one** `flyway migrate`:
1. Run `flyway info`. Look at the repeatable row: what is in its **Category** and **Version** columns?
2. Users need a city. Add a versioned migration `migrations/V3__add_city.sql` that adds `city TEXT` to `users`
   (Files panel: **+ New file**, type the path, write the SQL, save with **Ctrl+S**).
3. The `active_users` view must now also show the city: change `R__active_users.sql` so the view's columns
   are exactly `id, name, city` (in that order). Open it in the Files panel, edit, **Ctrl+S**. Run `flyway info`: what state does the repeatable show now?
4. Add a new repeatable `migrations/R__user_order_totals.sql` that creates a view `user_order_totals` with
   columns `user_id, order_total` = the sum of `orders.total` per user (one row per user that has orders).
5. `flyway migrate` once, then `flyway info`. How many rows does `R__active_users.sql` have now, and what states?

**Stop:** don't edit V1/V2; don't put the view change in a new V file (the view lives in its repeatable);
don't delete `shop.db` or rows; don't use `flyway repair`.

**Hints**
- A repeatable must work when it runs again on a database that already has the view: start it with
  `DROP VIEW IF EXISTS ...;` (look at the existing file).
- Sum per user: `SELECT user_id, SUM(total) AS order_total FROM orders GROUP BY user_id;`
- Why can the view mention `city` before V3 has run? Because on migrate Flyway runs **all pending versioned
  migrations first**, then the new/changed repeatables.
- `flyway info` states for repeatables: `Pending` (new file), `Outdated` (file changed since it ran), `Success`.

**What will be checked**
- V1/V2 unchanged; `V3__add_city.sql` adds city; only 3 V files
- history: V3 Success; `R__active_users.sql` has 2 successful rows (version empty); `R__user_order_totals.sql` 1 row
- `flyway validate` passes; users has city and 3 rows
- `active_users` columns `id,name,city`, rows Asha and Meera; `user_order_totals` gives 1 -> 1249, 3 -> 400
