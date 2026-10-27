#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
fresh_work
sqlite3 shop.db <<'SQL'
CREATE TABLE users  (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);
CREATE TABLE orders (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, total INTEGER NOT NULL);
INSERT INTO users  VALUES (1,'Asha'),(2,'Ravi'),(3,'Meera');
INSERT INTO orders VALUES (1,1,250),(2,2,400),(3,1,999);
SQL
banner "06-migrations / 01-sqlite-basics (Drill)"
