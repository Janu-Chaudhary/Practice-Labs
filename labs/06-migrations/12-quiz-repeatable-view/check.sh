#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 12-quiz-repeatable-view"
q() { sqlite3 shop.db "$1"; }
cols() { sqlite3 shop.db "SELECT group_concat(name, ',') FROM pragma_table_info('$1');"; }
check "V1 and V2 unchanged" '[ "$(cat migrations/V1__create_users.sql)" = "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1);" ] && [ "$(cat migrations/V2__create_orders.sql)" = "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" ]'
check "migrations/V3__add_city.sql adds city to users" 'grep -Eqi "alter table *users *add column *city" migrations/V3__add_city.sql'
check "no extra versioned files (only V1, V2, V3)" '[ "$(ls migrations | grep -c "^V")" = 3 ]'
check "R__active_users.sql still exists and now selects city" 'grep -qi "city" migrations/R__active_users.sql'
check "new repeatable migrations/R__user_order_totals.sql exists" '[ -f migrations/R__user_order_totals.sql ]'
check "history: V3 Success" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'3'"' AND success=1")" = 1 ]'
check "history: R__active_users.sql ran twice (old + changed checksum), version empty" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE script='"'R__active_users.sql'"' AND version IS NULL AND success=1")" = 2 ]'
check "history: R__user_order_totals.sql ran once" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE script='"'R__user_order_totals.sql'"' AND success=1")" = 1 ]'
check "flyway validate passes (nothing pending or outdated)" '"$LAB_DIR/../../bin/flyway" validate'
check "users has city; still 3 users" '[ "$(q "SELECT count(*) FROM pragma_table_info('"'users'"') WHERE name='"'city'"'")" = 1 ] && [ "$(q "SELECT count(*) FROM users")" = 3 ]'
check "view active_users = id,name,city with Asha and Meera only" '[ "$(cols active_users)" = "id,name,city" ] && [ "$(q "SELECT group_concat(name) FROM (SELECT name FROM active_users ORDER BY id)")" = "Asha,Meera" ]'
check "view user_order_totals = user_id,order_total: user 1 -> 1249, user 3 -> 400" '[ "$(cols user_order_totals)" = "user_id,order_total" ] && [ "$(q "SELECT group_concat(user_id || '"':'"' || order_total) FROM (SELECT * FROM user_order_totals ORDER BY user_id)")" = "1:1249,3:400" ]'
summary
