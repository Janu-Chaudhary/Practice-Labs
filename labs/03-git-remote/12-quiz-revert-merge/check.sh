#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "on main, no revert in progress, working tree clean" '[ "$(git branch --show-current)" = main ] && [ ! -f .git/REVERT_HEAD ] && [ -z "$(git status --porcelain)" ]'
check "history not rewritten: the pushed tip is still in main" 'git merge-base --is-ancestor "$(cat .git/lab-pushed)" main'
check "exactly one new commit (main has 7), and it is not a merge" '[ "$(git rev-list --count main)" -eq 7 ] && [ "$(git rev-parse main~1)" = "$(cat .git/lab-pushed)" ] && [ -z "$(git rev-list --no-walk --merges main)" ]'
check "last commit is a revert of the merge" 'git log -1 --format=%s main | grep -q "^Revert \"Merge branch .discount."'
check "discount.py is gone and app.py is back to the version before the merge" '! git cat-file -e main:discount.py 2>/dev/null && [ "$(git rev-parse main:app.py)" = "$(git rev-parse "$(cat .git/lab-base)":app.py)" ]'
check "main's own work kept: README.md and logging.cfg still there" 'git cat-file -e main:README.md && git cat-file -e main:logging.cfg'
check "pushed: remote main == local main" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
summary
