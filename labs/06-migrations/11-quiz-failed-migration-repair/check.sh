#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 11-quiz-failed-migration-repair"
q() { sqlite3 shop.db "$1"; }
F=migrations/02_add_total_paise.up.sql
check "01 files unchanged" '[ "$(cat migrations/01_create_orders.up.sql)" = "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" ]'
check "02 still has all three steps (add column, backfill, index)" 'grep -qi "add column *total_paise" '$F' && grep -qi "update *orders *set *total_paise" '$F' && grep -qi "create index *idx_orders_total_paise" '$F
check "02 index statement now points at the orders table (typo fixed)" 'grep -Eqi "create index *idx_orders_total_paise *on *orders *\(" '$F' && ! grep -qi "ordrs" '$F
check "02 script config file still there, unchanged (executeInTransaction=false)" 'grep -qx "executeInTransaction=false" migrations/02_add_total_paise.up.sql.conf'
check "history: no failed rows left" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE success=0")" = 0 ]'
check "history: exactly one row for 02, and it is Success" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'02'"'")" = 1 ] && [ "$(q "SELECT success FROM flyway_schema_history WHERE version='"'02'"'")" = 1 ]'
check "flyway validate passes" '"$LAB_DIR/../../bin/flyway" validate'
check "orders still has 3 rows, total_paise = total * 100 in every row" '[ "$(q "SELECT count(*) FROM orders WHERE total_paise = total*100")" = 3 ] && [ "$(q "SELECT count(*) FROM orders")" = 3 ]'
check "total_paise column exists once and index idx_orders_total_paise is on orders" '[ "$(q "SELECT count(*) FROM pragma_table_info('"'orders'"') WHERE name='"'total_paise'"'")" = 1 ] && [ "$(q "SELECT tbl_name FROM sqlite_master WHERE type='"'index'"' AND name='"'idx_orders_total_paise'"'")" = orders ]'
summary
