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
# history of this database:
#  - users was built by hand before Flyway -> baseline at 01
echo "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL);" > $M/01_create_users.up.sql
echo "DROP TABLE users;" > $M/01_create_users.down.sql
sqlite3 shop.db "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL); INSERT INTO users VALUES (1,'Asha'),(2,'Ravi'),(3,'Meera');"
fw baseline -baselineVersion=01 -baselineDescription="existing schema"
#  - 02, 03, 05 applied normally
echo "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" > $M/02_create_orders.up.sql
echo "DROP TABLE orders;" > $M/02_create_orders.down.sql
echo "ALTER TABLE users ADD COLUMN city TEXT;" > $M/03_add_city.up.sql
echo "ALTER TABLE users DROP COLUMN city;" > $M/03_add_city.down.sql
echo "CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);" > $M/05_create_coupons.up.sql
echo "DROP TABLE coupons;" > $M/05_create_coupons.down.sql
fw migrate
#  - 04 arrived late from a teammate and was applied out of order
echo "CREATE INDEX idx_orders_user ON orders (user_id);" > $M/04_index_orders.up.sql
echo "DROP INDEX idx_orders_user;" > $M/04_index_orders.down.sql
fw migrate -outOfOrder=true
sqlite3 shop.db "INSERT INTO orders VALUES (1,1,250),(2,2,400),(3,1,999);"
git add . && git commit -q -m "Migrations 01-05"
sqlite3 shop.db "SELECT checksum FROM flyway_schema_history WHERE version='03'" > .git/lab-03-sum
# then someone documented 03 with a comment, in place (no SQL change)
printf '%s\n' "-- city is nullable on purpose: old users have no city yet" "ALTER TABLE users ADD COLUMN city TEXT;" > $M/03_add_city.up.sql
git commit -q -am "Document why city is nullable"
path_tip
banner "06-migrations / 14-twist-history-detective (Twist)"
