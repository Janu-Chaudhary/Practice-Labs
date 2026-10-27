#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 05-quiz-password-length"
# pytest_at <rev> [args]: run pytest on a clean copy of that commit (like a temp worktree)
pytest_at() {
  local rev=$1 t rc; shift; t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider "$@" 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
check "on main, HEAD has 3 commits" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 3 ]'
check "your two commits sit on top of the original commit" '[ "$(git rev-parse HEAD~2)" = "$BASE" ]'
check "test_validate.py at HEAD~1 contains \"abcdefgh\"" 'git show HEAD~1:test_validate.py | grep -q abcdefgh'
check "validate.py at HEAD~1 has the original content" 'git diff --quiet "$BASE" HEAD~1 -- validate.py'
check "HEAD~1 commit message matches \"failing test\"" 'git log -1 --format=%B HEAD~1 | grep -qi "failing test"'
check "at HEAD~1 pytest really FAILS (your test caught the bug)" 'pytest_at HEAD~1 >/dev/null; [ $? -eq 1 ]'
check "at HEAD test_validate.py has at least 3 tests" '[ $(git show HEAD:test_validate.py | grep -c "^def test_") -ge 3 ]'
check "at HEAD all tests pass" 'pytest_at HEAD | grep -Eq "^([3-9]|[1-9][0-9]+) passed"'
check "nothing left uncommitted in validate.py / test_validate.py" 'git diff --quiet HEAD -- validate.py test_validate.py'
summary
