#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 13-twist-mock-to-fake  (runs your tests against 8 versions of orders.py)"
export PYTHONDONTWRITEBYTECODE=1 PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
# pytest_at <rev> [orders.py source file]: run the suite of <rev>, optionally with orders.py replaced
pytest_at() {
  local rev=$1 src=$2 t rc; t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  [ -n "$src" ] && cp "$src" "$t/orders.py"
  (cd "$t" && python3 -m pytest -q -p no:cacheprovider 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
# Write the correct orders.py (good.py) and 7 broken versions (m_<name>.py) into a folder.
make_versions() {
  python3 - "$1" <<'PY'
import sys, os
d = sys.argv[1]
head = '''class PostgresOrderRepo:
    def __init__(self, url):
        raise RuntimeError("needs a real database")


def place_order(repo, item, qty):
'''
good = '''    if qty < 1 or qty > 10:
        return 400
    repo.save({"item": item, "qty": qty})
    return 201
'''
mutants = {
    "saves_rejected_orders_too": '''    repo.save({"item": item, "qty": qty})
    if qty < 1 or qty > 10:
        return 400
    return 201
''',
    "never_saves": '''    if qty < 1 or qty > 10:
        return 400
    return 201
''',
    "saves_twice": good.replace('    return 201', '    repo.save({"item": item, "qty": qty})\n    return 201'),
    "saves_wrong_qty": good.replace('"qty": qty}', '"qty": 1}'),
    "saves_wrong_item": good.replace('"item": item', '"item": "pen"'),
    "accepts_0": good.replace("qty < 1", "qty < 0"),
    "rejects_10": good.replace("qty > 10", "qty >= 10"),
    "returns_200": good.replace("return 201", "return 200"),
}
open(os.path.join(d, "good.py"), "w").write(head + good)
for name, body in mutants.items():
    open(os.path.join(d, "m_" + name + ".py"), "w").write(head + body)
PY
}
# Which broken versions do the HEAD tests NOT catch? (tests still pass = mutant survived)
SURVIVORS=$(
  cd "$WORK" 2>/dev/null || exit 0
  git rev-parse -q --verify HEAD >/dev/null || exit 0
  d=$(mktemp -d); make_versions "$d"
  for f in "$d"/m_*.py; do
    n=$(basename "$f" .py); n=${n#m_}
    ( pytest_at HEAD "$f" >/dev/null && touch "$d/s_$n" ) &
  done
  wait; ls "$d" | sed -n 's/^s_//p'; rm -rf "$d"
)
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
check "on main, exactly 3 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 3 ] && [ "$(git rev-parse HEAD~2)" = "$BASE" ]'
check "HEAD~1 message contains \"failing test\"" 'git log -1 --format=%B HEAD~1 | grep -qi "failing test"'
check "HEAD~1 changed only test_orders.py" '[ "$(git diff --name-only HEAD~2 HEAD~1)" = test_orders.py ]'
check "no Mock left in test_orders.py" '! git show HEAD:test_orders.py | grep -q "Mock"'
check "test_orders.py defines a fake repo (a class with save and all)" 'git show HEAD:test_orders.py | grep -q "^class " && git show HEAD:test_orders.py | grep -q "def save" && git show HEAD:test_orders.py | grep -q "def all"'
check "at HEAD~1 pytest FAILS (your fake catches the bug)" 'pytest_at HEAD~1 >/dev/null; [ $? -eq 1 ]'
check "HEAD changed only orders.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = orders.py ]'
check "at HEAD all tests pass (at least 4)" 'pytest_at HEAD | grep -Eq "^([4-9]|[1-9][0-9]+) passed"'
check "your tests pass on a known-correct orders.py" 'd=$(mktemp -d); make_versions $d; pytest_at HEAD $d/good.py >/dev/null; r=$?; rm -rf $d; [ $r -eq 0 ]'
check "your tests catch all 8 broken versions (real assertions, not just \"was called\")" '[ -z "$SURVIVORS" ] && pytest_at HEAD >/dev/null'
if [ -n "$SURVIVORS" ]; then
  printf '%s\n' "$SURVIVORS" | sed 's/^/    not caught: /'
  hint "assert the status code AND exactly what the fake stored (repo.all() == [...]) for valid and rejected orders"
fi
check "fixed code: qty 0/11 -> 400 and nothing stored; qty 1/10 -> 201 and stored once" 'git show HEAD:orders.py | python3 -c "
import sys; ns = {}; exec(sys.stdin.read(), ns); p = ns[\"place_order\"]
class R:
    def __init__(self): self.o = []
    def save(self, o): self.o.append(dict(o))
    def all(self): return list(self.o)
for q, s, n in ((0, 400, 0), (11, 400, 0), (1, 201, 1), (10, 201, 1)):
    r = R(); assert p(r, \"pen\", q) == s and len(r.all()) == n
r = R(); p(r, \"ink\", 3); assert r.all() == [{\"item\": \"ink\", \"qty\": 3}]"'
summary
