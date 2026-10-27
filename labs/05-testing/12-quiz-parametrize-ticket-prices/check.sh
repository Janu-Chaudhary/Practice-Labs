#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 12-quiz-parametrize-ticket-prices  (runs your tests ~15 times, takes a few seconds)"
export PYTHONDONTWRITEBYTECODE=1 PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
# pytest_at <rev> [tickets.py source file]: run the suite of <rev>, optionally with tickets.py replaced
pytest_at() {
  local rev=$1 src=$2 t rc; t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  [ -n "$src" ] && cp "$src" "$t/tickets.py"
  (cd "$t" && python3 -m pytest -q -p no:cacheprovider 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
CORRECT='def ticket_price(age):
    if age < 0 or age > 120:
        raise ValueError("age must be between 0 and 120")
    if age < 5:
        return 0
    if age < 18:
        return 8
    if age < 65:
        return 15
    return 10
'
MUTANTS='age < 0 or|age <= 0 or
age < 0 or|age < -1 or
age > 120|age >= 120
age > 120|age > 121
age < 5|age <= 5
age < 5|age < 4
age < 18|age <= 18
age < 18|age < 17
age < 65|age <= 65
age < 65|age < 64
raise ValueError("age must be between 0 and 120")|return 0'
# Run the HEAD tests against every mutant (in parallel); collect the ones that survive (tests still pass).
SURVIVORS=$(
  cd "$WORK" 2>/dev/null || exit 0
  git rev-parse -q --verify HEAD >/dev/null || exit 0
  d=$(mktemp -d); i=0
  while IFS='|' read -r from to; do
    i=$((i+1)); printf '%s' "${CORRECT/"$from"/"$to"}" > "$d/m$i.py"
    ( pytest_at HEAD "$d/m$i.py" >/dev/null && echo "'$from' -> '$to'" > "$d/s$i" ) &
  done <<< "$MUTANTS"
  wait; cat "$d"/s* 2>/dev/null; rm -rf "$d"
)
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
check "on main, exactly 3 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 3 ] && [ "$(git rev-parse HEAD~2)" = "$BASE" ]'
check "HEAD~1 message contains \"failing test\"" 'git log -1 --format=%B HEAD~1 | grep -qi "failing test"'
check "HEAD~1 changed only test_tickets.py" '[ "$(git diff --name-only HEAD~2 HEAD~1)" = test_tickets.py ]'
check "tests use @pytest.mark.parametrize" 'git show HEAD:test_tickets.py | grep -q "@pytest.mark.parametrize"'
check "tests use pytest.raises(ValueError)" 'git show HEAD:test_tickets.py | grep -q "pytest.raises(ValueError"'
check "at HEAD~1 pytest FAILS (the table finds the bugs)" 'pytest_at HEAD~1 >/dev/null; [ $? -eq 1 ]'
check "HEAD changed only tickets.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = tickets.py ]'
check "at HEAD all tests pass (at least 12 test cases)" 'pytest_at HEAD | grep -Eq "^(1[2-9]|[2-9][0-9]|[1-9][0-9][0-9]+) passed"'
check "your tests also pass on a known-correct tickets.py" 'f=$(mktemp); printf "%s" "$CORRECT" > $f; pytest_at HEAD $f >/dev/null; r=$?; rm -f $f; [ $r -eq 0 ]'
check "every boundary mutant is killed (both sides of every edge, + the raise)" '[ -z "$SURVIVORS" ] && pytest_at HEAD >/dev/null'
if [ -n "$SURVIVORS" ]; then
  printf '%s\n' "$SURVIVORS" | sed 's/^/    mutant survived: /'
  hint "a surviving mutant means some edge is not tested on BOTH sides (e.g. 64 and 65)"
fi
check "fixed code: 4->0 5->8 17->8 18->15 64->15 65->10 120->10, -1 and 121 raise" 'git show HEAD:tickets.py | python3 -c "
import sys; ns = {}; exec(sys.stdin.read(), ns); p = ns[\"ticket_price\"]
assert [p(a) for a in (0,4,5,17,18,64,65,120)] == [0,0,8,8,15,15,10,10]
for bad in (-1, 121):
    try: p(bad)
    except ValueError: pass
    else: raise SystemExit(1)"'
summary
