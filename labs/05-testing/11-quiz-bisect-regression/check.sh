#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 11-quiz-bisect-regression"
export PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
pytest_at() {
  local rev=$1 t rc; shift; t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider "$@" 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
BAD=$(cd "$WORK" 2>/dev/null && git log --format=%H --grep='^Tidy pricing code$' "$BASE" 2>/dev/null | head -1)
check "answer.txt line 1 = the first bad commit (at least 7 characters of its hash)" \
  'a=$(head -1 answer.txt | tr -d "[:space:]"); [ ${#a} -ge 7 ] && [ -n "$BAD" ] && case "$BAD" in "$a"*) true;; *) false;; esac'
check "bisect is finished (git bisect reset was run)" '[ ! -f .git/BISECT_START ] && [ ! -f .git/BISECT_LOG ]'
check "on main, exactly 2 new commits on top of the original 9" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 11 ] && [ "$(git rev-parse HEAD~2)" = "$BASE" ]'
check "HEAD~1 message contains \"failing test\"" 'git log -1 --format=%B HEAD~1 | grep -qi "failing test"'
check "HEAD~1 changed only test files (test_*.py)" '[ -n "$(git diff --name-only HEAD~2 HEAD~1)" ] && ! git diff --name-only HEAD~2 HEAD~1 | grep -qv "^test_.*\.py$"'
check "at HEAD~1 pytest FAILS (your regression test catches the bug)" 'pytest_at HEAD~1 >/dev/null; [ $? -eq 1 ]'
check "HEAD changed only pricing.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = pricing.py ]'
check "at HEAD all tests pass (at least 5)" 'pytest_at HEAD | grep -Eq "^([5-9]|[1-9][0-9]+) passed"'
check "the fix works: 9 items -> 0.0, 10 items -> 0.10, 20 items -> 0.10" 'git show HEAD:pricing.py | python3 -c "
import sys; ns = {}; exec(sys.stdin.read(), ns); d = ns[\"bulk_discount\"]
assert d(9) == 0.0 and d(10) == 0.10 and d(20) == 0.10 and d(1) == 0.0"'
check "no uncommitted changes to tracked files" 'git diff --quiet HEAD'
summary
