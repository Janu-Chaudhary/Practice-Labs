# Solution - Demos 03

```bash
./traffic.sh > traffic.log 2>&1 &
./deploy.sh 2.4-rename                    # migration renames items -> order_items, then switch
./rollback.sh 2.3                         # code goes back; the column does not
curl -s localhost:8080/healthz            # {"status":"ok","version":"2.3"}  (SELECT 1 only)
curl -s 'localhost:8080/checkout?customer=asha'   # ERROR column "items" ... does not exist (v2.3)
docker exec t5-db psql -U postgres -c '\d orders'  # order_items, no items
docker exec t5-db psql -U postgres -c 'ALTER TABLE orders RENAME COLUMN order_items TO items;'
curl -s 'localhost:8080/checkout?customer=asha'   # ok ... (v2.3)
cd .. && ./check.sh
```

## Common wrong attempts
- Rolling back again, or `./deploy.sh 2.3` -> no change: the migration for 2.3 is "already
  applied" and nothing renames the column back. Only a new DB change fixes it.
- `ALTER TABLE orders ADD COLUMN items text` -> v2.3 inserts into `items` but `order_items` is
  still `NOT NULL` with no value: inserts still fail. Rename it back.
- Missing quotes around the SQL -> the shell splits it into many arguments. Keep it in `'...'`.
