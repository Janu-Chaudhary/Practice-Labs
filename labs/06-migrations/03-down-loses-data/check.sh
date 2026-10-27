#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 03-down-loses-data"
q() { sqlite3 shop.db "$1"; }
check "migrations/03_restore_bio.up.sql adds bio" 'grep -qi "add column *bio" migrations/03_restore_bio.up.sql'
check "migrations/03_restore_bio.down.sql drops bio" 'grep -qi "drop column *bio" migrations/03_restore_bio.down.sql'
check "history: 03 Success (from 03_restore_bio.up.sql)" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'03'"' AND script='"'03_restore_bio.up.sql'"' AND success=1")" = 1 ]'
check "users has a bio column again" 'q "SELECT bio FROM users LIMIT 1"'
check "users still has 2 rows" '[ "$(q "SELECT count(*) FROM users")" = 2 ]'
check "bio is NULL in every row (values are gone)" '[ "$(q "SELECT count(*) FROM users WHERE bio IS NULL")" = 2 ]'
check "answer.txt says NULL" '[ "$(tr -d "[:space:]" < answer.txt | tr "[:lower:]" "[:upper:]")" = NULL ]'
check "01/02 files unchanged" 'grep -qx "ALTER TABLE users DROP COLUMN bio;" migrations/02_drop_bio.up.sql && grep -qx "ALTER TABLE users ADD COLUMN bio text;" migrations/02_drop_bio.down.sql && [ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version IN ('"'01'"','"'02'"') AND success=1")" = 2 ]'
summary
