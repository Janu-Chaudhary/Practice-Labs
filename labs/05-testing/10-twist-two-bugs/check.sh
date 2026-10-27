#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 10-twist-two-bugs"
pytest_at() {
  local rev=$1 t rc; shift; t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  (cd "$t" && PYTHONDONTWRITEBYTECODE=1 python3 -m pytest -q -p no:cacheprovider "$@" 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
# shop_at <rev> <python-expr>: evaluate an expression against shop.py as committed at <rev>
shop_at() { git show "$1:shop.py" | python3 -c 'import sys; ns={}; exec(sys.stdin.read(), ns); sys.exit(0 if eval(sys.argv[1], ns) else 1)' "$2"; }
only() { [ "$(git diff --name-only "$1" "$2")" = "$3" ]; }
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
SHIP_OK='shipping_cost(50) == 0 and shipping_cost(49.99) == 5 and shipping_cost(10) == 5'
POST_OK='is_valid_postcode("3000") is True and is_valid_postcode("30000") is False and is_valid_postcode("30a0") is False'
check "on main, exactly 4 new commits (5 in total) on top of the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 5 ] && [ "$(git rev-parse HEAD~4)" = "$BASE" ]'
check "commit 1 (HEAD~3): message has \"failing test\", changes only test_shop.py" 'git log -1 --format=%B HEAD~3 | grep -qi "failing test" && only HEAD~4 HEAD~3 test_shop.py'
check "commit 1: pytest FAILS there" 'pytest_at HEAD~3 >/dev/null; [ $? -eq 1 ]'
check "commit 2 (HEAD~2): changes only shop.py, fixes shipping (50 is free), postcode still unfixed" 'only HEAD~3 HEAD~2 shop.py && shop_at HEAD~2 "$SHIP_OK" && ! shop_at HEAD~2 "$POST_OK"'
check "commit 2: pytest PASSES there" 'pytest_at HEAD~2 >/dev/null'
check "commit 3 (HEAD~1): message has \"failing test\", changes only test_shop.py" 'git log -1 --format=%B HEAD~1 | grep -qi "failing test" && only HEAD~2 HEAD~1 test_shop.py'
check "commit 3: pytest FAILS there" 'pytest_at HEAD~1 >/dev/null; [ $? -eq 1 ]'
check "commit 4 (HEAD): changes only shop.py, both rules now correct" 'only HEAD~1 HEAD shop.py && shop_at HEAD "$SHIP_OK" && shop_at HEAD "$POST_OK"'
check "commit 4: all tests pass (at least 5)" 'pytest_at HEAD | grep -Eq "^([5-9]|[1-9][0-9]+) passed"'
summary
