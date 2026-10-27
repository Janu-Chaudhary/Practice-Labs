#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-twist-wrong-branch"
check "main is back to 1 commit (\"Add greet\")" '[ "$(git rev-list --count main)" = 1 ] && [ "$(git log -1 --format=%s main)" = "Add greet" ]'
check "login.py does not exist at main" '! git cat-file -e main:login.py 2>/dev/null'
check "branch login exists" 'git rev-parse --verify -q refs/heads/login'
check "login has 3 commits" '[ "$(git rev-list --count login)" = 3 ]'
check "login tip is \"Validate login fields\"" '[ "$(git log -1 --format=%s login)" = "Validate login fields" ]'
check "login.py at login has valid()" 'git show login:login.py | grep -q "def valid"'
check "on branch login" '[ "$(git branch --show-current)" = login ]'
check "working tree clean" '[ -z "$(git status --porcelain)" ]'
summary
