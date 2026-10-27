#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-twist-kill-the-mutant  (runs the COMMITTED files)"
# at_head <cmd>: run a command in a clean copy of HEAD
at_head() {
  local t rc; t=$(mktemp -d); git archive HEAD | tar -x -C "$t"; cp "$WORK/.git/lab-base.mutants" "$t/mutants.py"  # pristine copy saved by setup.sh
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 eval "$1" >/dev/null 2>&1); rc=$?; rm -rf "$t"; return $rc
}
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
check "on main, exactly one new commit (2 in total)" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 2 ] && [ "$(git rev-parse HEAD~1)" = "$BASE" ]'
check "the commit changed only test_validate.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = test_validate.py ]'
check "all tests pass at HEAD" 'at_head "python3 -m pytest -q -p no:cacheprovider"'
check "every mutant is killed at HEAD (python3 mutants.py exits 0)" 'at_head "python3 mutants.py"'
summary
