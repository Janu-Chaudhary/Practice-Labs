#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 03-down-loses-data"
check "users has a bio column again" 'sqlite3 shop.db "SELECT bio FROM users LIMIT 1"'
check "users still has 2 rows" '[ "$(sqlite3 shop.db "SELECT count(*) FROM users")" = 2 ]'
check "bio is NULL in every row (values are gone)" '[ "$(sqlite3 shop.db "SELECT count(*) FROM users WHERE bio IS NULL")" = 2 ]'
check "history has no row for 02 (Flyway sees 02 as Pending)" '[ "$(sqlite3 shop.db "SELECT count(*) FROM flyway_schema_history WHERE version='"'02'"'")" = 0 ]'
check "history still has 01" '[ "$(sqlite3 shop.db "SELECT count(*) FROM flyway_schema_history WHERE version='"'01'"' AND success=1")" = 1 ]'
check "migration files unchanged" 'grep -qx "ALTER TABLE users DROP COLUMN bio;" migrations/02_drop_bio.up.sql && grep -qx "ALTER TABLE users ADD COLUMN bio text;" migrations/02_drop_bio.down.sql'
summary
