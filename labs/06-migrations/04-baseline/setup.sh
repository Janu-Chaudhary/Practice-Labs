#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_course
mkdir migrations
echo "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" > migrations/01_create_orders.up.sql
echo "CREATE INDEX idx_orders_user ON orders (user_id);" > migrations/02_index_orders.up.sql
echo "ALTER TABLE orders ADD COLUMN currency TEXT NOT NULL DEFAULT 'INR';" > migrations/03_add_currency.up.sql
echo "ALTER TABLE orders DROP COLUMN currency;" > migrations/03_add_currency.down.sql
# the database was built by hand long ago (same schema as 01 + 02), so it has NO history table
sqlite3 shop.db <<'SQL'
CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);
CREATE INDEX idx_orders_user ON orders (user_id);
INSERT INTO orders VALUES (1,1,250),(2,2,400),(3,1,999);
SQL
path_tip
banner "06-migrations / 04-baseline (Drill)"
