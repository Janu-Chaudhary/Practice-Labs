#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 06-quiz-orders-up-down"
q() { sqlite3 shop.db "$1"; }
hist() { [ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='$1' AND script='$2' AND success=1")" = 1 ]; }
# run the down files on a COPY of shop.db, newest first; print the schema + row count afterwards
downtest() { local t; t="$(mktemp -d)"; cp shop.db "$t/"
  sqlite3 "$t/shop.db" < migrations/04_create_coupons.down.sql && sqlite3 "$t/shop.db" < migrations/03_add_currency.down.sql &&
  sqlite3 "$t/shop.db" "SELECT count(*) FROM orders; SELECT name FROM pragma_table_info('orders'); SELECT name FROM sqlite_master WHERE name='coupons';"
  rm -rf "$t"; }
for f in 03_add_currency.up 03_add_currency.down 04_create_coupons.up 04_create_coupons.down; do
  check "migrations/$f.sql exists" "[ -s migrations/$f.sql ]"
done
check "01 and 02 untouched (flyway validate passes)" '"$LAB_DIR/../../bin/flyway" validate'
check "history: 03 applied from 03_add_currency.up.sql" 'hist 03 03_add_currency.up.sql'
check "history: 04 applied from 04_create_coupons.up.sql" 'hist 04 04_create_coupons.up.sql'
check "history: exactly 4 successful migrations" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE success=1")" = 4 ]'
check "orders still has 3 rows" '[ "$(q "SELECT count(*) FROM orders")" = 3 ]'
check "orders.currency exists and is INR on all 3 rows" '[ "$(q "SELECT count(*) FROM orders WHERE currency='"'INR'"'")" = 3 ]'
check "currency is NOT NULL" '[ "$(q "SELECT \"notnull\" FROM pragma_table_info('"'orders'"') WHERE name='"'currency'"'")" = 1 ]'
check "coupons table has columns code, percent" '[ "$(q "SELECT group_concat(name) FROM pragma_table_info('"'coupons'"')")" = "code,percent" ]'
check "down files (04 then 03) on a copy: coupons gone, currency gone, 3 rows kept" '[ "$(downtest | tr "\n" " ")" = "3 id user_id total " ]'
summary
