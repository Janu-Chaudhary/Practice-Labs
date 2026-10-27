#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo .
mkdir migrations
printf '%s\n' "CREATE TABLE users (id INTEGER PRIMARY KEY, user_name TEXT NOT NULL);" > migrations/01_create_users.sql
printf '%s\n' "ALTER TABLE users ADD COLUMN plan TEXT;" > migrations/02_add_billing.sql
printf '%s\n' "ALTER TABLE users ADD COLUMN full_name TEXT;" > migrations/03_add_full_name.sql
git add . && git commit -q -m "Add migrations 01 to 03"
git switch -q -c search
commit_file migrations/04_add_search_index.sql "CREATE INDEX idx_users_full_name ON users (full_name);" "Add search index migration"
git switch -q main
commit_file migrations/04_add_coupons.sql "CREATE TABLE coupons (code TEXT PRIMARY KEY, percent INTEGER NOT NULL);" "Add coupons migration"
git switch -q search
git rev-parse main > .git/lab-main-tip
git log --oneline --all --decorate
echo
banner "06-migrations / 05-quiz-timestamp-rename (Quiz-style, Quiz 2 Q17)"
