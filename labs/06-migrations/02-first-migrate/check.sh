#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 02-first-migrate"
H="SELECT count(*) FROM flyway_schema_history WHERE success=1 AND version="
check "shop.db exists (created by flyway migrate)" '[ -f shop.db ]'
check "migrations/V2__add_email.sql exists" '[ -f migrations/V2__add_email.sql ]'
check "V2 adds an email column" 'grep -qi "add column *email" migrations/V2__add_email.sql'
check "history table has version 1 (Success)" '[ "$(sqlite3 shop.db "$H'"'1'"'")" = 1 ]'
check "history table has version 2 (Success)" '[ "$(sqlite3 shop.db "$H'"'2'"'")" = 1 ]'
check "users has an email column" 'sqlite3 shop.db "SELECT email FROM users LIMIT 1"'
check "users still has 3 rows" '[ "$(sqlite3 shop.db "SELECT count(*) FROM users")" = 3 ]'
check "V1 file unchanged" 'grep -q "CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);" migrations/V1__create_users.sql && [ $(wc -l < migrations/V1__create_users.sql) = 2 ]'
summary
