#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 01-status-add-commit"
check "main has exactly 3 commits" '[ "$(git rev-list --count main)" = 3 ]'
check "commit HEAD~1 is \"Handle empty payload\"" '[ "$(git log -1 --format=%s HEAD~1)" = "Handle empty payload" ]'
check "HEAD~1 changed only app/server.py" '[ "$(git diff --name-only HEAD~2 HEAD~1)" = "app/server.py" ]'
check "app/server.py at HEAD~1 has the empty-payload check" 'git show HEAD~1:app/server.py | grep -q "if not payload"'
check "latest commit is \"Add webhook route\"" '[ "$(git log -1 --format=%s HEAD)" = "Add webhook route" ]'
check "latest commit adds routes/webhooks.py and .gitignore only" '[ "$(git diff --name-only HEAD~1 HEAD | sort | tr "\n" " ")" = ".gitignore routes/webhooks.py " ]'
check ".gitignore ignores *.log" 'git show HEAD:.gitignore | grep -qx "\*\.log"'
check "debug.log is NOT committed but still on disk" '! git cat-file -e HEAD:debug.log 2>/dev/null && [ -f debug.log ]'
check "working tree clean (git status --porcelain is empty)" '[ -z "$(git status --porcelain)" ]'
summary
