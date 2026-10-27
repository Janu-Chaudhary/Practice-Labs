#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_course
mkdir migrations
echo "CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);" > migrations/01_create_users.up.sql
echo "DROP TABLE users;" > migrations/01_create_users.down.sql
fw migrate
sqlite3 shop.db "INSERT INTO users (id, user_name) VALUES (1,'Asha Verma'),(2,'Ravi'),(3,'Meera');"
path_tip
banner "06-migrations / 09-twist-expand-contract (Twist)"
