#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "pushed history not rewritten (old tip is still in main)" 'git merge-base --is-ancestor "$(cat .git/lab-pushed)" main'
check "main has 5 commits" '[ "$(git rev-list --count main)" -eq 5 ]'
check "last commit is Revert \"Disable auth check\"" '[ "$(git log -1 --format=%s main)" = "Revert \"Disable auth check\"" ]'
check "auth.py at main checks login again" 'git show main:auth.py | grep -q "return user.is_logged_in"'
check "order totals are still there" 'git show main:orders.py | grep -q "def order_total"'
check "main is pushed (remote main == local main)" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
summary
