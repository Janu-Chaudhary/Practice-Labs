#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-twist-expand-contract"
q() { sqlite3 shop.db "$1"; }
ok() { [ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='$1' AND script='$2' AND success=1")" = 1 ]; }
cols() { sqlite3 "$1" "SELECT group_concat(name) FROM pragma_table_info('users')"; }
# copy, run 04.down then 02.down (03 is a data job: no reverse needed), print the result
downtest() { local t; t="$(mktemp -d)"; cp shop.db "$t/"
  sqlite3 "$t/shop.db" < migrations/04_drop_user_name.down.sql || { rm -rf "$t"; return 1; }
  echo "after04:$(cols "$t/shop.db"):$(sqlite3 "$t/shop.db" "SELECT count(*) FROM users WHERE user_name = full_name")"
  sqlite3 "$t/shop.db" < migrations/02_add_full_name.down.sql || { rm -rf "$t"; return 1; }
  echo "after02:$(cols "$t/shop.db"):$(sqlite3 "$t/shop.db" "SELECT group_concat(user_name) FROM (SELECT * FROM users ORDER BY id)")"
  rm -rf "$t"; }
check "history: 02 from 02_add_full_name.up.sql"     'ok 02 02_add_full_name.up.sql'
check "history: 03 from 03_backfill_full_name.up.sql" 'ok 03 03_backfill_full_name.up.sql'
check "history: 04 from 04_drop_user_name.up.sql"    'ok 04 04_drop_user_name.up.sql'
check "flyway validate passes" '"$LAB_DIR/../../bin/flyway" validate'
check "users now has exactly: id, full_name" '[ "$(cols shop.db)" = "id,full_name" ]'
check "names kept in full_name" '[ "$(q "SELECT group_concat(full_name) FROM (SELECT * FROM users ORDER BY id)")" = "Asha Verma,Ravi,Meera" ]'
check "02 and 04 have .down.sql files" '[ -s migrations/02_add_full_name.down.sql ] && [ -s migrations/04_drop_user_name.down.sql ]'
check "04.down on a copy brings user_name back WITH the names" 'downtest | grep -qx "after04:id,full_name,user_name:3"'
check "then 02.down leaves id, user_name with the names" 'downtest | grep -qx "after02:id,user_name:Asha Verma,Ravi,Meera"'
summary
