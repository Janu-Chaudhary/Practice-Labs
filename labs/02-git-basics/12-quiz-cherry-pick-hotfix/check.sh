#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 12-quiz-cherry-pick-hotfix"
check "no cherry-pick or merge in progress" '! git rev-parse -q --verify CHERRY_PICK_HEAD && ! git rev-parse -q --verify MERGE_HEAD'
check "main has 3 commits (exactly one new one)" '[ "$(git rev-list --count main)" = 3 ]'
check "main tip is \"Fix divide by zero\" with ONE parent (not a merge)" '[ "$(git log -1 --format=%s main)" = "Fix divide by zero" ] && [ "$(git rev-list --parents -n1 main | wc -w)" = 2 ]'
check "the commit below it is still \"Explain how to run\"" '[ "$(git log -1 --format=%s main~1)" = "Explain how to run" ]'
check "calc.py at main has the zero check" 'git show main:calc.py | grep -q "if b == 0"'
check "power.py and docs/USAGE.md are NOT on main (only the fix was copied)" '! git cat-file -e main:power.py 2>/dev/null && ! git cat-file -e main:docs/USAGE.md 2>/dev/null'
check "feature is NOT merged into main" '! git merge-base --is-ancestor feature main'
check "feature is unchanged (same tip as at setup)" '[ "$(git rev-parse feature)" = "$(cat .git/lab-feature-tip)" ]'
check "tag v1.0.1 exists and points at main's tip" '[ "$(git rev-parse -q --verify "v1.0.1^{commit}")" = "$(git rev-parse main)" ]'
check "v1.0.1 is an ANNOTATED tag (object type: tag)" '[ "$(git cat-file -t v1.0.1)" = tag ]'
check "v1.0.1 message is \"Hotfix: divide by zero\"" '[ "$(git tag -l --format="%(contents:subject)" v1.0.1)" = "Hotfix: divide by zero" ]'
check "v1.0.0 still points at the first commit" '[ "$(git rev-parse "v1.0.0^{commit}")" = "$(cat .git/lab-v100)" ]'
check "on main, working tree clean" '[ "$(git branch --show-current)" = main ] && [ -z "$(git status --porcelain)" ]'
summary
