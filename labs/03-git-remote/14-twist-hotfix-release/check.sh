#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "on main, nothing in progress, working tree clean" '[ "$(git branch --show-current)" = main ] && [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ] && [ ! -f .git/CHERRY_PICK_HEAD ] && [ -z "$(git status --porcelain)" ]'
check "main: teammate's \"Add wishlist\" kept as-is (no force push)" 'git -C remote.git merge-base --is-ancestor "$(cat .git/lab-teammate)" main'
check "main: linear, 5 commits, ends with \"Fix price rounding\" then \"Add dark mode\"" '[ -z "$(git rev-list --merges main)" ] && [ "$(git rev-list --count main)" -eq 5 ] && [ "$(git log -1 --format=%s main)" = "Add dark mode" ] && [ "$(git log -1 --format=%s main~1)" = "Fix price rounding" ] && [ "$(git rev-parse main~2)" = "$(cat .git/lab-teammate)" ]'
check "main pushed: remote main == local main" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
check "release-1.0 on origin = old release tip + exactly one commit \"Fix price rounding\"" '[ "$(git -C remote.git rev-parse release-1.0~1)" = "$(cat .git/lab-release)" ] && [ "$(git -C remote.git log -1 --format=%s release-1.0)" = "Fix price rounding" ]'
check "release-1.0 has the fix (round(x, 2)) but NOT wishlist.py or theme.py" 'git -C remote.git show release-1.0:price.py | grep -q "round(x, 2)" && ! git -C remote.git cat-file -e release-1.0:wishlist.py 2>/dev/null && ! git -C remote.git cat-file -e release-1.0:theme.py 2>/dev/null'
check "local release-1.0 exists, tracks origin/release-1.0, equals origin" '[ "$(git rev-parse --abbrev-ref release-1.0@{upstream})" = origin/release-1.0 ] && [ "$(git rev-parse release-1.0)" = "$(git -C remote.git rev-parse release-1.0)" ]'
summary
