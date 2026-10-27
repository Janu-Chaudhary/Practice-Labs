#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
EXP='def greet(name):
    return f"Hi there, {name}! Welcome back."'
echo "Checking 06-quiz-merge-conflict"
check "no merge in progress (MERGE_HEAD gone)" '! git rev-parse -q --verify MERGE_HEAD'
check "feature is merged into main" 'git merge-base --is-ancestor feature main'
check "greet.py at main has the expected content" '[ "$(git show main:greet.py | sed "s/[[:space:]]*$//")" = "$EXP" ]'
check "main has 4 commits" '[ "$(git rev-list --count main)" = 4 ]'
check "main tip is a merge commit (2 parents)" '[ "$(git rev-list --parents -n1 main | wc -w)" = 3 ]'
check "no conflict markers in greet.py" '! grep -qE "^(<<<<<<<|=======|>>>>>>>)" greet.py'
check "branch feature still exists" 'git rev-parse --verify -q refs/heads/feature'
check "on main, working tree clean" '[ "$(git branch --show-current)" = main ] && [ -z "$(git status --porcelain)" ]'
summary
