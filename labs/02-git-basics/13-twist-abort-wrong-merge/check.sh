#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
EXPR='flask==3.0.0
requests==2.31.0
gunicorn==22.0.0
pytest==8.2.0'
echo "Checking 13-twist-abort-wrong-merge"
check "no merge in progress" '! git rev-parse -q --verify MERGE_HEAD'
check "experiment is NOT merged into main" '! git merge-base --is-ancestor experiment main'
check "feature IS merged into main" 'git merge-base --is-ancestor feature main'
check "main has 4 commits (Add app, Add gunicorn, Add pytest, merge)" '[ "$(git rev-list --count main)" = 4 ]'
check "main tip is a merge whose second parent is feature" '[ "$(git rev-list --parents -n1 main | wc -w)" = 3 ] && [ "$(git rev-parse main^2)" = "$(git rev-parse feature)" ]'
check "requirements.txt at main keeps BOTH new lines, in the right order" '[ "$(git show main:requirements.txt | sed "s/[[:space:]]*$//")" = "$EXPR" ]'
check "app.py at main is the Shop v2 version (no experimental banner)" 'git show main:app.py | grep -q "Shop v2" && ! git show main:app.py | grep -q EXPERIMENTAL'
check "no conflict markers anywhere in main" '! git grep -qE "^(<<<<<<<|=======|>>>>>>>)" main'
check "branches feature and experiment still exist" 'git rev-parse -q --verify refs/heads/feature && git rev-parse -q --verify refs/heads/experiment'
check "on main, working tree clean" '[ "$(git branch --show-current)" = main ] && [ -z "$(git status --porcelain)" ]'
summary
