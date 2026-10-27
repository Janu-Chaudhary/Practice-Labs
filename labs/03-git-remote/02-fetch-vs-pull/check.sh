#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking..."
check "main has 3 commits (yours + the teammate's 2)" '[ "$(git rev-list --count main)" -eq 3 ]'
check "no merge commit was made (fast-forward)" '[ -z "$(git rev-list --merges main)" ]'
check "main == origin/main == remote main" '[ "$(git rev-parse main)" = "$(git rev-parse origin/main)" ] && [ "$(git rev-parse main)" = "$(git -C remote.git rev-parse main)" ]'
check "config.py and README.md are in your working directory" '[ -f config.py ] && [ -f README.md ]'
check "working tree clean" '[ -z "$(git status --porcelain)" ]'
summary
