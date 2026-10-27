#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "branch payments exists" 'git rev-parse --verify -q refs/heads/payments'
check "payments is the commit \"Add refund handler\"" '[ "$(git log -1 --format=%s payments)" = "Add refund handler" ]'
check "payments has 3 commits" '[ "$(git rev-list --count payments)" -eq 3 ]'
check "you are on main" '[ "$(git branch --show-current)" = main ]'
check "main was not changed (1 commit, not merged)" '[ "$(git rev-list --count main)" -eq 1 ]'
summary
