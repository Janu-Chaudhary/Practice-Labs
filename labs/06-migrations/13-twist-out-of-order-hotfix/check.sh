#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 13-twist-out-of-order-hotfix"
q() { sqlite3 shop.db "$1"; }
M=migrations
rank() { sqlite3 shop.db "SELECT installed_rank FROM flyway_schema_history WHERE version='$1' AND success=1"; }
check "answer.txt: the state flyway info showed for the late files (Ignored)" '[ "$(tr -d "[:space:]" < answer.txt | tr "[:upper:]" "[:lower:]")" = ignored ]'
check "teammate hotfix files keep their name 202610221500_add_order_status.*" '[ -f $M/202610221500_add_order_status.up.sql ] && [ -f $M/202610221500_add_order_status.down.sql ]'
check "your notes migration renamed: 202610271100_add_order_notes.up.sql / .down.sql" 'grep -qi "add column *notes" $M/202610271100_add_order_notes.up.sql && grep -qi "drop column *notes" $M/202610271100_add_order_notes.down.sql'
check "old 202610231000_add_order_notes.* files are gone" '! ls $M/202610231000_* >/dev/null 2>&1'
check "history: 202610221500 applied, AFTER 202610251200 (out of order)" '[ -n "$(rank 202610221500)" ] && [ "$(rank 202610221500)" -gt "$(rank 202610251200)" ]'
check "history: 202610271100 applied; 202610231000 never applied" '[ -n "$(rank 202610271100)" ] && [ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'202610231000'"'")" = 0 ]'
check "history: no failed rows; 4 migrations in total" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE success=0")" = 0 ] && [ "$(q "SELECT count(*) FROM flyway_schema_history")" = 4 ]'
check "flyway.toml unchanged (outOfOrder used only for this one run, not saved)" '! grep -qi "outOfOrder" flyway.toml'
check "flyway validate passes" '"$LAB_DIR/../../bin/flyway" validate'
check "orders: 3 rows, status = placed, notes column exists" '[ "$(q "SELECT count(*) FROM orders WHERE status='"'placed'"'")" = 3 ] && [ "$(q "SELECT count(*) FROM pragma_table_info('"'orders'"') WHERE name='"'notes'"'")" = 1 ]'
check "teammate's hotfix commit untouched and still in history" 'git merge-base --is-ancestor "$(cat .git/lab-hotfix-commit)" HEAD && git diff --quiet "$(cat .git/lab-hotfix-commit)" HEAD -- $M/202610221500_add_order_status.up.sql'
check "renamed notes migration is committed; tree clean (answer.txt may be untracked)" 'git cat-file -e HEAD:$M/202610271100_add_order_notes.up.sql && git cat-file -e HEAD:$M/202610271100_add_order_notes.down.sql && [ -z "$(git status --porcelain | grep -v " answer.txt$")" ]'
summary
