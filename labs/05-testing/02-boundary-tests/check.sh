#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 02-boundary-tests"
# killed_by_tests <sed-expr>: put a small bug (a "mutant") into a copy of age.py; your tests must go red
killed_by_tests() {
  local t rc; t=$(mktemp -d); cp age.py test_age.py "$t"/
  sed -i "$1" "$t/age.py"
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider >/dev/null 2>&1); rc=$?
  rm -rf "$t"; [ $rc -eq 1 ]
}
check "age.py is unchanged" 'git diff --quiet HEAD -- age.py'
check "test_age.py has at least 5 test functions" '[ $(grep -c "^def test_" test_age.py) -ge 5 ]'
check "all tests pass (pytest exit code 0)" 'PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider'
check "a test for exactly 18 exists (bug >= 18 -> > 18 would be caught)" 'killed_by_tests "s/age >= ADULT_AGE/age > ADULT_AGE/"'
check "a test for 17 exists (bug >= 18 -> >= 17 would be caught)" 'killed_by_tests "s/age >= ADULT_AGE/age >= ADULT_AGE - 1/"'
check "uses pytest.raises for a negative age" 'grep -q "pytest.raises(ValueError" test_age.py'
check "the negative-age test really checks the error (removing the raise is caught)" 'killed_by_tests "s/raise ValueError.*/return False/"'
summary
