#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "you are on feature" '[ "$(git branch --show-current)" = feature ]'
check "main did not move (still \"Update changelog\")" '[ "$(git rev-parse main)" = "$(cat .git/lab-main)" ]'
check "feature is built on top of main" 'git merge-base --is-ancestor main feature'
check "feature tip is \"Strip whitespace in notes\"" '[ "$(git log -1 --format=%s feature)" = "Strip whitespace in notes" ]'
check "feature has 4 commits and no merge commit (rebased, not merged)" '[ "$(git rev-list --count feature)" -eq 4 ] && [ -z "$(git rev-list --merges feature)" ]'
check "feature tip contains CHANGELOG.md" 'git cat-file -e feature:CHANGELOG.md'
check "feature commits got new ids" '[ "$(git rev-parse feature)" != "$(cat .git/lab-old-feature)" ]'
summary
