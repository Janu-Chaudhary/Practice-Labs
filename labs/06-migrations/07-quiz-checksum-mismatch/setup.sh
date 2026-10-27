#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
git_repo .
toml_course
echo "shop.db" > .gitignore
mkdir migrations
echo "CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);" > migrations/01_create_users.up.sql
echo "DROP TABLE users;" > migrations/01_create_users.down.sql
echo "ALTER TABLE users ADD COLUMN plan TEXT;" > migrations/02_add_billing.up.sql
echo "ALTER TABLE users DROP COLUMN plan;" > migrations/02_add_billing.down.sql
git add . && git commit -q -m "Add migrations 01 and 02"
# the database: 01 + 02 applied, 3 users
fw migrate
sqlite3 shop.db "SELECT checksum FROM flyway_schema_history WHERE version='02'" > .git/lab-02-sum
sqlite3 shop.db "INSERT INTO users (id, user_name, plan) VALUES (1,'Asha','pro'),(2,'Ravi','free'),(3,'Meera','free');"
# a teammate then "fixed" the already-applied 02 in place
printf '%s\n' "ALTER TABLE users ADD COLUMN plan TEXT;" "ALTER TABLE users ADD COLUMN billing_email TEXT;" > migrations/02_add_billing.up.sql
printf '%s\n' "ALTER TABLE users DROP COLUMN billing_email;" "ALTER TABLE users DROP COLUMN plan;" > migrations/02_add_billing.down.sql
git commit -q -am "Fix billing migration: add billing_email"
git rev-parse HEAD > .git/lab-fix-commit
path_tip
banner "06-migrations / 07-quiz-checksum-mismatch (Quiz-style)"
