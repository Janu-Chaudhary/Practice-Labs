#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 11-quiz-amend-forgotten-file"
check "on branch main" '[ "$(git branch --show-current)" = main ]'
check "main still has exactly 2 commits (amended, not a new commit)" '[ "$(git rev-list --count main)" = 2 ]'
check "first commit is still \"Add greet\"" '[ "$(git log -1 --format=%s main~1)" = "Add greet" ]'
check "last commit message is exactly \"Add settings loader\"" '[ "$(git log -1 --format=%s main)" = "Add settings loader" ]'
check "the typo commit \"Add setings loader\" is no longer on main" '! git log main --format=%s | grep -qx "Add setings loader"'
check "last commit contains loader.py and settings.json" 'git cat-file -e main:loader.py && git cat-file -e main:settings.json'
check "settings.json at main has the theme" 'git show main:settings.json | grep -q "\"theme\": \"dark\""'
check "todo.txt was NOT changed by any commit (private line not committed)" '! git show main:todo.txt | grep -q private && git diff --quiet main~1 main -- todo.txt'
check "todo.txt on disk still has your private line" 'grep -q "private" todo.txt'
check "only change left: todo.txt modified, NOT staged" '[ "$(git status --porcelain)" = " M todo.txt" ]'
summary
