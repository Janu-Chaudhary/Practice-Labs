#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "on main, no rebase/cherry-pick in progress, working tree clean" '[ "$(git branch --show-current)" = main ] && [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ] && [ ! -f .git/CHERRY_PICK_HEAD ] && [ -z "$(git status --porcelain)" ]'
check "main has exactly 5 commits and no merge commit" '[ "$(git rev-list --count main)" -eq 5 ] && [ -z "$(git rev-list --merges main)" ]'
check "\"Add cart\" and \"Add discount\" are back as the ORIGINAL commits (same ids)" '[ "$(git rev-parse main~1)" = "$(cat .git/lab-discount)" ] && [ "$(git rev-parse main~2)" = "$(cat .git/lab-cart)" ]'
check "tip of main is \"Fix typo in README\", sitting on top of \"Add discount\"" '[ "$(git log -1 --format=%s main)" = "Fix typo in README" ]'
check "files at main: cart.py, discount.py, README is \"# Orders API\"" 'git cat-file -e main:cart.py && git cat-file -e main:discount.py && [ "$(git show main:README.md)" = "# Orders API" ]'
check "pushed: remote main == local main" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
summary
