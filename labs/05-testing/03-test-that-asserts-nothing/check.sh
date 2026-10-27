#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 03-test-that-asserts-nothing"
# pytest_at <rev> [args]: run pytest on a clean copy of that commit (not your working folder)
pytest_at() {
  local rev=$1 t rc; shift; t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider "$@" 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
# passes_with_correct_code: your test must PASS once discount.py is fixed (so you asserted the right value)
passes_with_correct_code() {
  local t rc; t=$(mktemp -d); git archive HEAD | tar -x -C "$t"
  printf 'def apply_discount(price, percent):\n    return price * (100 - percent) / 100\n' > "$t/discount.py"
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider >/dev/null 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
check "exactly one new commit on main (2 in total)" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 2 ]'
check "new commit message contains \"failing test\"" 'git log -1 --format=%s | grep -qi "failing test"'
check "the commit changed only test_discount.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = test_discount.py ]'
check "discount.py is NOT fixed yet (unchanged)" 'git diff --quiet HEAD~1 HEAD -- discount.py && git diff --quiet HEAD -- discount.py'
check "test_ten_percent_off_200 now has an assert" 'git show HEAD:test_discount.py | sed -n "/def test_ten_percent_off_200/,/^def /p" | grep -q "assert"'
check "at HEAD, test_ten_percent_off_200 FAILS (it caught the bug)" 'pytest_at HEAD test_discount.py::test_ten_percent_off_200 >/dev/null; [ $? -eq 1 ]'
check "at HEAD, the other test still passes" 'pytest_at HEAD test_discount.py::test_zero_percent_changes_nothing >/dev/null'
check "your assert expects the right value (passes once discount.py is fixed)" 'passes_with_correct_code'
summary
