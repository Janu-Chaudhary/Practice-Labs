#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 06-quiz-duplicate-email"
pytest_at() {
  local rev=$1 t rc; shift; t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider "$@" 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
# behaves_at <rev>: the committed signup.py returns 201 then 409 for the same email, and stores it once
behaves_at() {
  git show "$1:signup.py" | python3 -c '
import sys; ns = {}; exec(sys.stdin.read(), ns)
r = ns["FakeUserRepo"](); s = ns["signup"]
assert s(r, "a@x.com") == 201 and s(r, "a@x.com") == 409 and r.count() == 1
assert s(r, "b@x.com") == 201 and s(r, "nope") == 400'
}
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
check "on main, exactly 3 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 3 ] && [ "$(git rev-parse HEAD~2)" = "$BASE" ]'
check "HEAD~1 message contains \"failing test\"" 'git log -1 --format=%B HEAD~1 | grep -qi "failing test"'
check "HEAD~1 changed only test_signup.py" '[ "$(git diff --name-only HEAD~2 HEAD~1)" = test_signup.py ]'
check "HEAD~1 test expects 409" 'git show HEAD~1:test_signup.py | grep -q 409'
check "HEAD~1 test uses the fake repo, not a Mock" 'git show HEAD~1:test_signup.py | grep -q FakeUserRepo && ! git show HEAD~1:test_signup.py | grep -q Mock'
check "at HEAD~1 pytest FAILS (test reproduces the bug)" 'pytest_at HEAD~1 >/dev/null; [ $? -eq 1 ]'
check "HEAD changed only signup.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = signup.py ]'
check "at HEAD all tests pass (at least 3)" 'pytest_at HEAD | grep -Eq "^([3-9]|[1-9][0-9]+) passed"'
check "the fix works: same email twice -> 201 then 409, stored once" 'behaves_at HEAD'
summary
