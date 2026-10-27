#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_mig.sh"
need_docker
fresh_work
toml_default
mkdir migrations
cat > migrations/V1__create_users.sql <<'SQL'
CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);
INSERT INTO users (id, user_name) VALUES (1, 'Asha'), (2, 'Ravi'), (3, 'Meera');
SQL
path_tip
banner "06-migrations / 02-first-migrate (Drill)"
