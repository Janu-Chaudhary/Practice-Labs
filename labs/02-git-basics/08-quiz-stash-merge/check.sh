#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 08-quiz-stash-merge"
check "no merge in progress" '! git rev-parse -q --verify MERGE_HEAD'
check "feature is merged into main" 'git merge-base --is-ancestor feature main'
check "main has 4 commits" '[ "$(git rev-list --count main)" = 4 ]'
check "main tip is a merge commit (2 parents)" '[ "$(git rev-list --parents -n1 main | wc -w)" = 3 ]'
check "notes.txt at main has the v2 heading" 'git show main:notes.txt | grep -qx "# Team notes (v2)"'
check "WIP line is NOT committed" '! git show main:notes.txt | grep -q WIP'
check "notes.txt on disk has v2 heading AND your WIP line" 'grep -qx "# Team notes (v2)" notes.txt && grep -q "WIP: write on-call rota" notes.txt'
check "WIP is an unstaged change again (only notes.txt modified)" '[ "$(git status --porcelain)" = " M notes.txt" ]'
check "stash is empty (you popped it)" '[ -z "$(git stash list)" ]'
check "no conflict markers" '! grep -qE "^(<<<<<<<|>>>>>>>)" notes.txt'
summary
