#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 07-quiz-undo-extra-commit"
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null); FIX=$(cat "$WORK/.git/lab-fix" 2>/dev/null)
check "on main with exactly 3 commits" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 3 ]'
check "HEAD is your original fix commit (the test + fix commits were not rewritten)" '[ "$(git rev-parse HEAD)" = "$FIX" ]'
check "the \"wip\" commit is gone (not reverted with a 4th commit)" '! git log --format=%s | grep -qx wip'
check "notes.txt still exists on disk" '[ -f notes.txt ] && grep -q "49.5" notes.txt'
check "notes.txt is not tracked by git" '! git ls-files --error-unmatch notes.txt'
check "nothing is staged" 'git diff --cached --quiet'
check "grade.py has no debug print (matches the fix commit)" 'git diff --quiet HEAD -- grade.py && ! grep -q DEBUG grade.py'
check "pytest passes" 'PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider'
summary
