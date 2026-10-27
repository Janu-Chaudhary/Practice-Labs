#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "teammate's \"Add health endpoint\" kept as-is" 'git merge-base --is-ancestor "$(cat .git/lab-teammate)" main'
check "main is linear: no merge commits" '[ -z "$(git rev-list --merges main)" ]'
check "main has 3 commits, yours on top" '[ "$(git rev-list --count main)" -eq 3 ] && [ "$(git log -1 --format=%s main)" = "Add search endpoint" ] && [ "$(git log -1 --format=%s main~1)" = "Add health endpoint" ]'
check "routes.txt at main has orders, health, search (in that order)" '[ "$(git show main:routes.txt)" = "$(printf "GET /orders\nGET /health\nGET /search")" ]'
check "no rebase in progress" '[ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ]'
check "main is pushed (remote main == local main)" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
summary
