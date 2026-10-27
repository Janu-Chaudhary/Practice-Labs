#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_default
mkdir migrations
echo "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1);" > migrations/V1__create_users.sql
echo "CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);" > migrations/V2__create_orders.sql
cat > migrations/R__active_users.sql <<'SQL'
-- Repeatable: Flyway re-runs this file whenever its checksum changes.
DROP VIEW IF EXISTS active_users;
CREATE VIEW active_users AS
  SELECT id, name FROM users WHERE active = 1;
SQL
fw migrate
sqlite3 shop.db "INSERT INTO users (id, name, active) VALUES (1,'Asha',1),(2,'Ravi',0),(3,'Meera',1);"
sqlite3 shop.db "INSERT INTO orders (id, user_id, total) VALUES (1,1,250),(2,3,400),(3,1,999);"
path_tip
banner "06-migrations / 12-quiz-repeatable-view (Quiz-style)"
