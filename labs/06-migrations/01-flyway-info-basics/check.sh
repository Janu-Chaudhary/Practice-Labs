#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 01-flyway-info-basics"
q() { sqlite3 shop.db "$1"; }
line() { sed -n "${1}p" answer.txt | tr -d "[:space:]"; }
check "answer.txt exists" '[ -f answer.txt ]'
check "answer.txt line 1: schema version before you migrated (02)" '[ "$(line 1)" = 02 ] || [ "$(line 1)" = 2 ]'
check "answer.txt line 2: how many migrations were Pending (2)" '[ "$(line 2)" = 2 ]'
check "history: 01, 02, 03 Success" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE success=1 AND version IN ('"'01'"','"'02'"','"'03'"')")" = 3 ]'
check "history: 04 NOT applied (you stopped at 03)" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'04'"'")" = 0 ]'
check "users has city; 3 users and 3 orders kept" '[ "$(q "SELECT count(*) FROM pragma_table_info('"'users'"') WHERE name='"'city'"'")" = 1 ] && [ "$(q "SELECT count(*) FROM users")" = 3 ] && [ "$(q "SELECT count(*) FROM orders")" = 3 ]'
check "migration files unchanged" '[ "$(cat migrations/03_add_city.up.sql)" = "ALTER TABLE users ADD COLUMN city TEXT;" ] && [ "$(cat migrations/04_create_coupons.up.sql)" = "CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);" ]'
summary
