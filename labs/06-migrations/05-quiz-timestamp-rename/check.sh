#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 05-quiz-timestamp-rename"
check "you are on branch search" '[ "$(git branch --show-current)" = search ]'
check "migrations/202610071517_add_search_index.sql at search contains \"CREATE INDEX\"" 'git show search:migrations/202610071517_add_search_index.sql | grep -q "CREATE INDEX"'
check "migrations/04_add_search_index.sql is gone (at search and on disk)" '! git cat-file -e search:migrations/04_add_search_index.sql 2>/dev/null && [ ! -e migrations/04_add_search_index.sql ]'
check "migrations/04_add_coupons.sql exists at search" 'git cat-file -e search:migrations/04_add_coupons.sql'
check "coupons migration left as it is" '[ "$(git show search:migrations/04_add_coupons.sql)" = "$(git show main:migrations/04_add_coupons.sql)" ]'
check "main is merged into search" 'git merge-base --is-ancestor main search'
check "main itself was not changed" '[ "$(git rev-parse main)" = "$(cat .git/lab-main-tip)" ]'
check "working tree clean (everything committed)" '[ -z "$(git status --porcelain)" ]'
check "nothing pushed / no remote added" '[ -z "$(git remote)" ]'
summary
