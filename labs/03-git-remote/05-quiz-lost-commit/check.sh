#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "rate-limit is the commit \"Add rate limit config\"" '[ "$(git log -1 --format=%s rate-limit)" = "Add rate limit config" ]'
check "rate-limit is merged into main" 'git merge-base --is-ancestor rate-limit main'
check "main has 4 commits" '[ "$(git rev-list --count main)" -eq 4 ]'
check "main is pushed to origin (remote main == local main)" '[ "$(git -C remote.git rev-parse main)" = "$(git rev-parse main)" ]'
check "rate-limit was NOT pushed" '! git -C remote.git rev-parse --verify -q refs/heads/rate-limit'
check "limits.py is in main" 'git cat-file -e main:limits.py'
summary
