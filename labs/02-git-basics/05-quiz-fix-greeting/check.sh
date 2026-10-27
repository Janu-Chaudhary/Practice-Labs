#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
EXP='def greet(name):
    return f"Hello, {name}!"'
echo "Checking 05-quiz-fix-greeting"
check "branch fix-greeting exists" 'git rev-parse --verify -q refs/heads/fix-greeting'
check "on branch fix-greeting" '[ "$(git branch --show-current)" = fix-greeting ]'
check "greet.py at fix-greeting has the expected content" '[ "$(git show fix-greeting:greet.py | sed "s/[[:space:]]*$//")" = "$EXP" ]'
check "fix-greeting is the commit \"Use f-string in greeting\"" '[ "$(git log -1 --format=%s fix-greeting)" = "Use f-string in greeting" ]'
check "fix-greeting has 2 commits (one new)" '[ "$(git rev-list --count fix-greeting)" = 2 ]'
check "main untouched (1 commit)" '[ "$(git rev-list --count main)" = 1 ]'
check "working tree clean" '[ -z "$(git status --porcelain)" ]'
summary
