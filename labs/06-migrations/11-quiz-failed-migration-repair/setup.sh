#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_course
mkdir migrations
echo "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" > migrations/01_create_orders.up.sql
echo "DROP TABLE orders;" > migrations/01_create_orders.down.sql
fw migrate
sqlite3 shop.db "INSERT INTO orders (id, user_id, total) VALUES (1,1,250),(2,2,400),(3,1,999);"
# 02: three steps with a typo in its LAST statement, marked non-transactional
cat > migrations/02_create_coupons.up.sql <<'SQL'
-- coupons table, two starter coupons, and an index for "find coupons by percent"
CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);
INSERT INTO coupons (code, percent) VALUES ('WELCOME10', 10), ('FESTIVE20', 20);
CREATE INDEX idx_coupons_percent ON coupns (percent);
SQL
cat > migrations/02_create_coupons.down.sql <<'SQL'
DROP INDEX IF EXISTS idx_coupons_percent;
DROP TABLE coupons;
SQL
cat > migrations/02_create_coupons.up.sql.conf <<'CONF'
# Script config for 02: run WITHOUT a transaction (like MySQL, where DDL can't be rolled back).
executeInTransaction=false
CONF
# the deploy that went wrong: 02 fails on its last statement, after the first two already committed
"$FLYWAY" migrate >/dev/null 2>&1
[ "$(sqlite3 shop.db "SELECT count(*) FROM flyway_schema_history WHERE version='02' AND success=0")" = 1 ] \
  && [ "$(sqlite3 shop.db "SELECT count(*) FROM coupons")" = 2 ] \
  || { echo "${R}setup: expected a failed 02 row and a half-done coupons table${N}"; exit 1; }
path_tip
banner "06-migrations / 11-quiz-failed-migration-repair (Quiz-style)"
