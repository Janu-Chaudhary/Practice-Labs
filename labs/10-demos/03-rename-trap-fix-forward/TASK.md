# Demos 03 - The rename that rollback can't undo, then fix forward (slide 15, steps 7-9)

**Start state (Reset lab did this):** platform up, v2.3 live (deployed through the pipeline).

**What the professor shows:** the slide-6 poll, for real. `2.4-rename` is the same group-order
code, but its migration **renames** `items` to `order_items`. During the deploy the migration runs
while v2.3 is still serving, so checkouts already fail. Rolling back to v2.3 "worked last time"...
and now `/healthz` is ok while **every** checkout fails: v2.3 asks for `items`, the table only has
`order_items`. The only way out is **forward**: a new DB change that renames the column back.

**Slide ideas:**
- **Migrate before deploy**, and old and new code run side by side, so every migration must keep
  the **old** code working. `ADD COLUMN` is safe; `RENAME` / `DROP` are not.
- **Code is reversible, data is not.** Rollback restores code, never the database.
- `/healthz` (`SELECT 1`) is a readiness check, not a business-logic test.
- Done safely it is **expand/contract**: add `order_items`, write both, backfill, read the new one,
  and drop `items` last (the irreversible step).

Read first in the Files panel: `app/releases/2.4-rename/migrate.sql`.

## Do this, in order
1. `./traffic.sh > traffic.log 2>&1 &`
2. `./deploy.sh 2.4-rename` - watch `[3/6] Migrate ... RENAME COLUMN items TO order_items`.
   In `traffic.log`: `ERROR column "items" of relation "orders" does not exist (v2.3)` appears
   **before** the switch to 2.4-rename.
3. `./rollback.sh 2.3`
4. `curl -s localhost:8080/healthz` -> `{"status":"ok","version":"2.3"}` (healthy!)
   `curl -s 'localhost:8080/checkout?customer=asha'` -> `ERROR column "items" ... (v2.3)`;
   `traffic.log` is all red.
5. See the real columns: `docker exec t5-db psql -U postgres -c '\d orders'` -> `order_items`.
6. Fix forward:
   `docker exec t5-db psql -U postgres -c 'ALTER TABLE orders RENAME COLUMN order_items TO items;'`
7. `curl -s 'localhost:8080/checkout?customer=asha'` -> `ok ... (v2.3)`; `traffic.log` recovers.

Trap: this manual `ALTER` is not in `schema_migrations` (it still lists `2.4-rename`). In a real
team you write it as the next migration file.

## What will be checked
- `schema_migrations` lists `2.4-rename`; `traffic.log` shows the `column "items"` error on v2.3
- `/healthz` says 2.3; exactly one app container, from `tiffingo:2.3`
- `orders` has the column `items` and no `order_items`
- asha's checkout and kabir's group order answer `ok ... (v2.3)`
