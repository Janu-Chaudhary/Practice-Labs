#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
git_repo .
toml_course
echo "shop.db" > .gitignore
mkdir migrations
M=migrations
echo "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" > $M/202610201000_create_orders.up.sql
echo "DROP TABLE orders;" > $M/202610201000_create_orders.down.sql
git add . && git commit -q -m "Add orders migration"
echo "CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);" > $M/202610251200_create_coupons.up.sql
echo "DROP TABLE coupons;" > $M/202610251200_create_coupons.down.sql
git add . && git commit -q -m "Add coupons migration"
# your local database: both applied, 3 orders
fw migrate
sqlite3 shop.db "INSERT INTO orders (id, user_id, total) VALUES (1,1,250),(2,2,400),(3,1,999);"
# the teammate's hotfix arrives via git pull: written + deployed to production on Oct 22
echo "ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT 'placed';" > $M/202610221500_add_order_status.up.sql
echo "ALTER TABLE orders DROP COLUMN status;" > $M/202610221500_add_order_status.down.sql
git add . && git -c user.name="Teammate" -c user.email="mate@example.com" commit -q -m "Hotfix: order status (already deployed to production)"
git rev-parse HEAD > .git/lab-hotfix-commit
# your own forgotten work from Oct 23: never committed, never applied anywhere
echo "ALTER TABLE orders ADD COLUMN notes TEXT;" > $M/202610231000_add_order_notes.up.sql
echo "ALTER TABLE orders DROP COLUMN notes;" > $M/202610231000_add_order_notes.down.sql
path_tip
banner "06-migrations / 13-twist-out-of-order-hotfix (Twist)"
