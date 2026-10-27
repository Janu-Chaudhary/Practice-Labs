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
# 02: a backfill migration with a typo in its LAST statement, marked non-transactional
cat > migrations/02_add_total_paise.up.sql <<'SQL'
-- store money as whole paise instead of rupees
ALTER TABLE orders ADD COLUMN total_paise INTEGER;
UPDATE orders SET total_paise = total * 100;
CREATE INDEX idx_orders_total_paise ON ordrs (total_paise);
SQL
cat > migrations/02_add_total_paise.down.sql <<'SQL'
DROP INDEX IF EXISTS idx_orders_total_paise;
ALTER TABLE orders DROP COLUMN total_paise;
SQL
cat > migrations/02_add_total_paise.up.sql.conf <<'CONF'
# Script config for 02: run WITHOUT a transaction (like MySQL, where DDL can't be rolled back).
executeInTransaction=false
CONF
# the deploy that went wrong: 02 fails on its last statement, after the first two already committed
"$FLYWAY" migrate >/dev/null 2>&1
[ "$(sqlite3 shop.db "SELECT count(*) FROM flyway_schema_history WHERE version='02' AND success=0")" = 1 ] \
  || { echo "${R}setup: expected a failed 02 row${N}"; exit 1; }
path_tip
banner "06-migrations / 11-quiz-failed-migration-repair (Quiz-style)"
