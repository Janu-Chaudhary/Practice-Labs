#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_course
mkdir migrations
echo "CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);" > migrations/01_create_users.up.sql
echo "ALTER TABLE users ADD COLUMN plan TEXT;" > migrations/02_add_billing.up.sql
fw migrate
sqlite3 shop.db "INSERT INTO users (id, user_name, plan) VALUES (1,'Asha','pro'),(2,'Ravi','free'),(3,'Meera','free');"
echo "ALTER TABLE users ADD COLUMN full_name text;" > migrations/03_add_full_name.up.sql
echo "ALTER TABLE users DROP COLUMN full_name;"     > migrations/03_add_full_name.down.sql
# "Before the deploy, you run its statement by hand" - straight into the database, no runner
sqlite3 shop.db "ALTER TABLE users ADD COLUMN full_name text;"
path_tip
banner "06-migrations / 08-quiz-hand-run-sql (Quiz-style, Quiz 2 Q8 made real)"
