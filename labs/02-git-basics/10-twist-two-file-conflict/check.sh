#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
EXPG='def greet(name):
    return f"Hi, {name}! Good to see you."'
EXPC='PORT = 9000
DEBUG = False'
echo "Checking 10-twist-two-file-conflict"
check "no merge in progress" '! git rev-parse -q --verify MERGE_HEAD'
check "feature is merged into main" 'git merge-base --is-ancestor feature main'
check "main has 4 commits, tip has 2 parents" '[ "$(git rev-list --count main)" = 4 ] && [ "$(git rev-list --parents -n1 main | wc -w)" = 3 ]'
check "greet.py at main has the expected content" '[ "$(git show main:greet.py | sed "s/[[:space:]]*$//")" = "$EXPG" ]'
check "config.py at main is the feature version (PORT = 9000)" '[ "$(git show main:config.py | sed "s/[[:space:]]*$//")" = "$EXPC" ]'
check "docs/USAGE.md from feature exists at main" 'git cat-file -e main:docs/USAGE.md'
check "no conflict markers anywhere in main" '! git grep -qE "^(<<<<<<<|=======|>>>>>>>)" main'
check "on main, working tree clean" '[ "$(git branch --show-current)" = main ] && [ -z "$(git status --porcelain)" ]'
summary
