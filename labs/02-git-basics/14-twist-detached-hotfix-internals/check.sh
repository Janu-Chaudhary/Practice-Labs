#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 14-twist-detached-hotfix-internals"
check "branch v1-hotfix exists" 'git rev-parse -q --verify refs/heads/v1-hotfix'
check "v1-hotfix has 3 commits, tip \"Fix retries for 1.0\"" '[ "$(git rev-list --count v1-hotfix)" = 3 ] && [ "$(git log -1 --format=%s v1-hotfix)" = "Fix retries for 1.0" ]'
check "the hotfix commit sits directly on the v1.0 commit" '[ "$(git rev-parse v1-hotfix~1)" = "$(cat .git/lab-v10)" ]'
check "config.py at v1-hotfix is exactly RETRIES = 3" '[ "$(git show v1-hotfix:config.py | sed "s/[[:space:]]*$//")" = "RETRIES = 3" ]'
check "the hotfix changed only config.py" '[ "$(git diff --name-only v1.0 v1-hotfix)" = config.py ]'
check "main is unchanged (same tip as at setup)" '[ "$(git rev-parse main)" = "$(cat .git/lab-main-tip)" ]'
check "tag v1.0 still points at the release commit" '[ "$(git rev-parse "v1.0^{commit}")" = "$(cat .git/lab-v10)" ]'
check "back on branch main (not detached), clean tree" '[ "$(git branch --show-current)" = main ] && [ -z "$(git status --porcelain)" ]'
check "answers.txt exists" '[ -f answers.txt ]'
check "answers line 1: the tree hash of v1-hotfix (at least 7 chars)" 'a=$(sed -n 1p answers.txt | tr -d "[:space:]"); t=$(git rev-parse "v1-hotfix^{tree}"); [ ${#a} -ge 7 ] && [ "${t#"$a"}" != "$t" ]'
check "answers line 2: the object type of v1.0" '[ "$(sed -n 2p answers.txt | tr -d "[:space:]")" = tag ]'
check "answers line 3: the file that shares banner.txt's blob" '[ "$(sed -n 3p answers.txt | tr -d "[:space:]")" = motd.txt ]'
summary
