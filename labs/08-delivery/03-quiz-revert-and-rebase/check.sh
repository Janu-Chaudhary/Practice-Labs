#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
EXPECTED='TIMEOUT_SECONDS = 30

MENU = {"paneer thali": 180, "lassi": 60}


def checkout(customer, group=False):
    items = ["paneer thali", "lassi"]
    total = sum(MENU[i] for i in items)
    return {"customer": customer, "total": total, "kind": "single"}'
export EXPECTED
echo "Checking..."
check "\"Add group orders\" is still in history (undone with a new commit, not erased)" 'git log --format=%s main | grep -qx "Add group orders"'
check "teammate's \"Raise timeout to 30 seconds\" is in main" 'git log --format=%s main | grep -qx "Raise timeout to 30 seconds"'
check "main has exactly 5 commits" '[ "$(git rev-list --count main)" -eq 5 ]'
check "latest commit message is exactly \"Roll back group orders\"" '[ "$(git log -1 --format=%s main)" = "Roll back group orders" ]'
check "the rollback commit sits on top of the teammate's commit" '[ "$(git log -1 --format=%s main~1)" = "Raise timeout to 30 seconds" ]'
check "history is a straight line (no merge commits)" '[ "$(git rev-list --merges --count main)" -eq 0 ]'
check "app.py at main: group code gone, timeout 30 kept" '[ "$(git show main:app.py)" = "$EXPECTED" ]'
check "footer.txt change is kept" 'git show main:footer.txt | grep -q "fresh tiffins"'
check "pushed: origin main == local main" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
check "nothing half-done (no rebase/revert in progress, tree clean)" '[ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ] && [ ! -f .git/REVERT_HEAD ] && [ -z "$(git status --porcelain)" ]'
summary
