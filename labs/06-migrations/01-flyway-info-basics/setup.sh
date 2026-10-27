#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_course
mkdir migrations
m() { echo "$2" > "migrations/$1.up.sql"; echo "$3" > "migrations/$1.down.sql"; }
m 01_create_users  "CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);" "DROP TABLE users;"
m 02_create_orders "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" "DROP TABLE orders;"
# the database: 01 and 02 applied, some data
fw migrate
sqlite3 shop.db "INSERT INTO users VALUES (1,'Asha'),(2,'Ravi'),(3,'Meera'); INSERT INTO orders VALUES (1,1,250),(2,2,400),(3,1,999);"
# two newer migrations pulled from git, not applied yet
m 03_add_city       "ALTER TABLE users ADD COLUMN city TEXT;" "ALTER TABLE users DROP COLUMN city;"
m 04_create_coupons "CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);" "DROP TABLE coupons;"
path_tip
banner "06-migrations / 01-flyway-info-basics (Drill)"
