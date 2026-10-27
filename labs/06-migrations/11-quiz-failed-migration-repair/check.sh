#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 11-quiz-failed-migration-repair"
q() { sqlite3 shop.db "$1"; }
FW="$LAB_DIR/../../bin/flyway"
F=migrations/02_create_coupons.up.sql
# run all migrations on a brand-new, empty database (like CI or a new teammate) and count the coupons
freshtest() { local t; t="$(mktemp -d)"; cp -r flyway.toml migrations "$t/"
  ( cd "$t" && "$FW" migrate >/dev/null 2>&1 ) && sqlite3 "$t/shop.db" "SELECT count(*) FROM coupons; SELECT tbl_name FROM sqlite_master WHERE name='idx_coupons_percent';"
  rm -rf "$t"; }
check "01 file unchanged" '[ "$(cat migrations/01_create_orders.up.sql)" = "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" ]'
check "02 still has all three steps (create table, insert coupons, index)" 'grep -qi "create table" '$F' && grep -qi "WELCOME10" '$F' && grep -qi "FESTIVE20" '$F' && grep -qi "create index" '$F
check "02 index statement now points at the coupons table (typo fixed)" 'grep -Eqi "idx_coupons_percent *on *coupons *\(" '$F' && ! grep -qi "coupns" '$F
check "02 script config file still there, unchanged (executeInTransaction=false)" 'grep -qx "executeInTransaction=false" migrations/02_create_coupons.up.sql.conf'
check "history: no failed rows left" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE success=0")" = 0 ]'
check "history: exactly one row for 02, and it is Success" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'02'"'")" = 1 ] && [ "$(q "SELECT success FROM flyway_schema_history WHERE version='"'02'"'")" = 1 ]'
check "flyway validate passes" '"$FW" validate'
check "coupons has exactly the 2 coupons (no duplicates); orders still 3 rows" '[ "$(q "SELECT group_concat(code||'"':'"'||percent) FROM (SELECT * FROM coupons ORDER BY percent)")" = "WELCOME10:10,FESTIVE20:20" ] && [ "$(q "SELECT count(*) FROM orders")" = 3 ]'
check "index idx_coupons_percent exists on coupons" '[ "$(q "SELECT tbl_name FROM sqlite_master WHERE type='"'index'"' AND name='"'idx_coupons_percent'"'")" = coupons ]'
check "a brand-new empty database also migrates: coupons with 2 rows + the index" '[ "$(freshtest | tr "\n" " ")" = "2 coupons " ]'
summary
