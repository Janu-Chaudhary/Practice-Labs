#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 08-quiz-hand-run-sql"
q() { sqlite3 shop.db "$1"; }
col() { [ "$(q "SELECT count(*) FROM pragma_table_info('users') WHERE name='$1'")" = 1 ]; }
check "03 and 04 files unchanged" '[ "$(cat migrations/03_add_full_name.up.sql)" = "ALTER TABLE users ADD COLUMN full_name text;" ] && [ "$(cat migrations/04_add_phone.up.sql)" = "ALTER TABLE users ADD COLUMN phone text;" ]'
check "history: 03 recorded as Success" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'03'"' AND success=1")" = 1 ]'
check "history: 04 recorded as Success" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'04'"' AND success=1")" = 1 ]'
check "flyway migrate now has nothing to do (validate passes)" '"$LAB_DIR/../../bin/flyway" validate'
check "users has full_name (once)" 'col full_name'
check "users has phone (04 really ran, it was not just recorded)" 'col phone'
check "3 users kept with names and plans" '[ "$(q "SELECT group_concat(user_name||'"':'"'||plan) FROM (SELECT * FROM users ORDER BY id)")" = "Asha:pro,Ravi:free,Meera:free" ]'
summary
