#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 01-sqlite-basics"
check "orders has 4 rows" '[ "$(sqlite3 shop.db "SELECT count(*) FROM orders")" = 4 ]'
check "order 4 is user 2, total 750" '[ "$(sqlite3 shop.db "SELECT user_id, total FROM orders WHERE id=4")" = "2|750" ]'
check "users table untouched (3 rows)" '[ "$(sqlite3 shop.db "SELECT count(*) FROM users")" = 3 ]'
check "answer.txt exists" '[ -f answer.txt ]'
check "answer.txt holds the count of orders with total > 300" '[ "$(tr -d "[:space:]" < answer.txt)" = "$(sqlite3 shop.db "SELECT count(*) FROM orders WHERE total > 300")" ]'
summary
