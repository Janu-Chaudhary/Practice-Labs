#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_course
mkdir migrations
echo "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" > migrations/01_create_orders.up.sql
echo "CREATE INDEX idx_orders_user ON orders (user_id);" > migrations/02_index_orders.up.sql
fw migrate
sqlite3 shop.db "INSERT INTO orders VALUES (1,1,250),(2,2,400),(3,1,999);"
path_tip
banner "06-migrations / 06-quiz-orders-up-down (Quiz-style, Quiz 2 Q18 reconstruction)"
