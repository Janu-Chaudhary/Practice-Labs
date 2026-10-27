#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "a remote called origin exists and points at remote.git" '[[ "$(git remote get-url origin)" == *remote.git ]]'
check "main is pushed: remote.git main == local main" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
check "main tracks origin/main (pushed with -u)" '[ "$(git rev-parse --abbrev-ref main@{upstream})" = origin/main ]'
check "main has 3 commits, the last is \"Add docs\"" '[ "$(git rev-list --count main)" -eq 3 ] && [ "$(git log -1 --format=%s main)" = "Add docs" ]'
check "docs.md is in the commit on origin" 'git -C remote.git cat-file -e main:docs.md'
summary
