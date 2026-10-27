#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "branch leak is the commit that added .env (\"Add config loader\")" '[ "$(git log -1 --format=%s leak)" = "Add config loader" ]'
check "main has 6 commits, last is \"Ignore .env\"" '[ "$(git rev-list --count main)" -eq 6 ] && [ "$(git log -1 --format=%s main)" = "Ignore .env" ]'
check "the last commit changed only .gitignore" '[ "$(git diff-tree --no-commit-id --name-only -r main)" = ".gitignore" ]'
check ".env is ignored now" 'git check-ignore -q .env'
check ".env is not in main and still on disk" '! git cat-file -e main:.env && [ -f .env ]'
summary
