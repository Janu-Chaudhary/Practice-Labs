#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-load/01-n-plus-one-join"
export PYTHONDONTWRITEBYTECODE=1 PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
# py_at <rev> <python code>: run python code inside a fresh copy of <rev>
py_at() {
  local t rc; t=$(mktemp -d)
  git archive "$1" | tar -x -C "$t"
  (cd "$t" && python3 -c "$2" 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
pytest_at() {
  local t rc; t=$(mktemp -d)
  git archive "$1" | tar -x -C "$t"
  (cd "$t" && python3 -m pytest -q -p no:cacheprovider 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
HIDDEN='
import sqlite3
from bookings import list_bookings_with_trains as f
c = sqlite3.connect(":memory:")
c.executescript("""CREATE TABLE trains (id INTEGER PRIMARY KEY, train_no TEXT NOT NULL,
  from_station TEXT NOT NULL, to_station TEXT NOT NULL);
CREATE TABLE bookings (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, pnr TEXT NOT NULL,
  train_id INTEGER NOT NULL REFERENCES trains(id));""")
st = ["PUNE", "CSMT", "NDLS", "SBC", "HWH", "MAS"]
for i in range(1, 31):
    c.execute("INSERT INTO trains VALUES (?,?,?,?)", (i, str(12000 + i * 7), st[i % 6], st[(i * 5 + 1) % 6]))
bid = 100
for k in range(40):
    bid += 3
    c.execute("INSERT INTO bookings VALUES (?,?,?,?)", (bid, 3 if k % 2 == 0 else 4, "PNR%d" % bid, (k * 11) % 30 + 1))
c.commit()
want = [{"pnr": p, "train_no": n, "from": a, "to": b} for p, n, a, b in c.execute(
    "SELECT b.pnr, t.train_no, t.from_station, t.to_station FROM bookings b JOIN trains t ON t.id=b.train_id WHERE user_id=3 ORDER BY b.id")]
assert len(want) == 20
q = []
c.set_trace_callback(q.append)
got = f(c, 3)
c.set_trace_callback(None)
assert len(q) <= 2, ("queries", len(q))
assert got == want, "wrong result"
assert f(c, 999) == []
'
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
check "on main, exactly 2 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 2 ] && [ "$(git rev-parse HEAD~1)" = "$BASE" ]'
check "the new commit changes only bookings.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = bookings.py ]'
check "commit message contains N+1" 'git log -1 --format=%B | grep -q "N+1"'
check "test_bookings.py and db.py unchanged (committed and on disk)" 'git diff --quiet "$BASE" -- test_bookings.py db.py && git diff --quiet "$BASE" HEAD -- test_bookings.py db.py'
check "pytest passes at HEAD (3 tests)" 'pytest_at HEAD | grep -q "^3 passed"'
check "hidden DB: user with 20 bookings -> at most 2 queries, exact same list; no bookings -> []" 'py_at HEAD "$HIDDEN"'
summary
