#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 14-twist-history-detective"
q() { sqlite3 shop.db "$1"; }
ans() { tr -d "[:space:]" < "$1" | tr "[:upper:]" "[:lower:]"; }
check "q1.txt: last migration Flyway ran = 04 (applied out of order)" '[ "$(ans q1.txt)" = 04 ]'
check "q2.txt: current schema version = 05" '[ "$(ans q2.txt)" = 05 ]'
check "q3.txt: state of 04 = Out of Order" '[ "$(ans q3.txt)" = outoforder ]'
check "q4.txt: 01 (covered by the BASELINE row, its SQL never ran)" '[ "$(ans q4.txt)" = 01 ]'
check "03 still contains the comment and the ALTER" 'grep -q "^-- city is nullable" migrations/03_add_city.up.sql && grep -qi "add column city" migrations/03_add_city.up.sql'
check "no commits added, no tracked file changed (q*.txt may be untracked)" '[ "$(git log --oneline | wc -l)" = 2 ] && [ -z "$(git status --porcelain | grep -v " q[0-9].txt$")" ]'
check "history checksum of 03 changed (repaired to the commented file)" '[ "$(q "SELECT checksum FROM flyway_schema_history WHERE version='"'03'"'")" != "$(cat .git/lab-03-sum)" ]'
check "flyway validate passes" '"$LAB_DIR/../../bin/flyway" validate'
check "history still 5 rows; 3 users; 3 orders" '[ "$(q "SELECT count(*) FROM flyway_schema_history")" = 5 ] && [ "$(q "SELECT count(*) FROM users")" = 3 ] && [ "$(q "SELECT count(*) FROM orders")" = 3 ]'
summary
