#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
git_repo .
toml_course
echo "shop.db" > .gitignore
mkdir migrations
m() { echo "$2" > "migrations/$1.up.sql"; echo "$3" > "migrations/$1.down.sql"; }
m 01_create_users    "CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);" "DROP TABLE users;"
m 02_create_products "CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT NOT NULL, price INTEGER NOT NULL);" "DROP TABLE products;"
m 03_create_orders   "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" "DROP TABLE orders;"
m 04_index_orders    "CREATE INDEX idx_orders_user ON orders (user_id);" "DROP INDEX idx_orders_user;"
git add . && git commit -q -m "Add migrations 01 to 04"
fw migrate                                   # your local shop.db: 01..04
sqlite3 shop.db "INSERT INTO users VALUES (1,'Asha'),(2,'Ravi'); INSERT INTO products VALUES (1,'Mug',300);"
git switch -q -c reviews
m 05_create_reviews  "CREATE TABLE reviews (id INTEGER PRIMARY KEY, product_id INTEGER NOT NULL, stars INTEGER NOT NULL);" "DROP TABLE reviews;"
git add . && git commit -q -m "Add reviews migration"
git switch -q main
m 05_create_wishlist "CREATE TABLE wishlist (user_id INTEGER NOT NULL, product_id INTEGER NOT NULL);" "DROP TABLE wishlist;"
git add . && git commit -q -m "Add wishlist migration"
git rev-parse main > .git/lab-main-tip
git switch -q reviews
git log --oneline --all --graph
echo
path_tip
banner "06-migrations / 10-twist-two-branches-05 (Twist)"
