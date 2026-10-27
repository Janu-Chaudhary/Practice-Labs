#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 07-quiz-checksum-mismatch"
q() { sqlite3 shop.db "$1"; }
FIRST='$(git rev-list --max-parents=0 HEAD)'
check "02_add_billing.up.sql is back to the applied version" "git diff --quiet $FIRST HEAD -- migrations/02_add_billing.up.sql"
check "02_add_billing.down.sql is back to the original too" "git diff --quiet $FIRST HEAD -- migrations/02_add_billing.down.sql"
check "a new migration 03_*.up.sql adds billing_email" 'ls migrations/03_*.up.sql >/dev/null && grep -qi "add column *billing_email" migrations/03_*.up.sql'
check "03 has a reverse migration 03_*.down.sql that drops billing_email" 'ls migrations/03_*.down.sql >/dev/null && grep -qi "drop column *billing_email" migrations/03_*.down.sql'
check "flyway validate passes" '"$LAB_DIR/../../bin/flyway" validate'
check "history: 03 Success" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'03'"' AND success=1")" = 1 ]'
check "history checksum of 02 was not repaired (still the original)" '[ "$(q "SELECT count(*) FROM flyway_schema_history WHERE version='"'02'"' AND checksum=$(cat .git/lab-02-sum)")" = 1 ]'
check "users has billing_email and still 3 rows with their plans" '[ "$(q "SELECT count(*) FROM users WHERE billing_email IS NULL AND plan IS NOT NULL")" = 3 ]'
check "history not rewritten (teammate commit still there)" 'git merge-base --is-ancestor "$(cat .git/lab-fix-commit)" HEAD'
check "everything committed (shop.db ignored)" '[ -z "$(git status --porcelain)" ]'
summary
