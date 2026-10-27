#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "teammate's \"Add README\" is still on origin (no force push)" 'git -C remote.git merge-base --is-ancestor "$(cat .git/lab-teammate)" main'
check "your \"Log each request\" is on origin" 'git -C remote.git merge-base --is-ancestor "$(cat .git/lab-mine)" main'
check "main is pushed (remote main == local main)" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
check "main has 4 commits (Add app, both commits, merge commit)" '[ "$(git rev-list --count main)" -eq 4 ]'
check "app.py still has your logging line, README.md exists" 'git show main:app.py | grep -q "print(\"request:\"" && git cat-file -e main:README.md'
summary
