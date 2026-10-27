#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "main has 2 commits" '[ "$(git rev-list --count main)" -eq 2 ]'
check "last commit is \"Add discount\"" '[ "$(git log -1 --format=%s main)" = "Add discount" ]'
check "discount.py is in the last commit" 'git cat-file -e main:discount.py'
check "debug.log is NOT in the last commit" '! git cat-file -e main:debug.log'
check "debug.log still exists in the folder (not deleted)" '[ -f debug.log ]'
check "nothing left staged" 'git diff --cached --quiet'
summary
