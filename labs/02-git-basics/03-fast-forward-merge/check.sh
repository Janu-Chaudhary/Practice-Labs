#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 03-fast-forward-merge"
check "feature is merged into main" 'git merge-base --is-ancestor feature main'
check "main and feature point at the same commit (fast-forward)" '[ "$(git rev-parse main)" = "$(git rev-parse feature)" ]'
check "main has 3 commits (no merge commit was created)" '[ "$(git rev-list --count main)" = 3 ]'
check "no commit on main has two parents" '[ -z "$(git rev-list --merges main)" ]'
check "test_calc.py exists at main" 'git cat-file -e main:test_calc.py'
check "branch feature still exists" 'git rev-parse --verify -q refs/heads/feature'
check "you are on main" '[ "$(git branch --show-current)" = main ]'
check "working tree clean" '[ -z "$(git status --porcelain)" ]'
summary
