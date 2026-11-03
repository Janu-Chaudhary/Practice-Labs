#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-load/05-twist-slow-departures"
export PYTHONDONTWRITEBYTECODE=1 PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
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
# Checker's own DB built from HEAD's migrations, different data
HIDDEN_DB='
import glob, random, sqlite3
def build():
    c = sqlite3.connect(":memory:")
    for p in sorted(glob.glob("migrations/*.sql")):
        c.executescript(open(p).read())
    r = random.Random(99); st = ["AAA", "BBB", "CCC", "DDD", "EEE"]
    c.executemany("INSERT INTO trains (id, train_no, from_station, to_station, journey_date) VALUES (?,?,?,?,?)",
        [(i, "%05d" % (90000 - i * 7 % 9000), r.choice(st), "ZZZ", "2026-12-%02d" % r.randint(1, 10)) for i in range(1, 3001)])
    c.executemany("INSERT INTO bookings (id, train_id, pnr) VALUES (?,?,?)",
        [(j, r.randint(1, 2500), "P%d" % j) for j in range(1, 9001)])   # trains 2501+ have no bookings
    c.commit()
    return c
'
RESULTS="$HIDDEN_DB"'
from departures import departures
c = build()
REF = ("SELECT t.train_no, t.to_station, count(b.id) FROM trains t LEFT JOIN bookings b ON b.train_id = t.id"
       " WHERE t.from_station = ? AND t.journey_date = ? GROUP BY t.id ORDER BY t.train_no")
zero = 0
for s, d in [("AAA", "2026-12-03"), ("CCC", "2026-12-07"), ("EEE", "2026-12-10"), ("XXX", "2026-12-01")]:
    want = [{"train_no": a, "to": b, "booked": n} for a, b, n in c.execute(REF, (s, d))]
    zero += sum(1 for w in want if w["booked"] == 0)
    q = []
    c.set_trace_callback(q.append)
    got = departures(c, s, d)
    c.set_trace_callback(None)
    assert got == want, (s, d, "wrong board")
    assert len(q) <= 2, (s, d, len(q), "queries")
assert zero > 0
'
PLANS="$HIDDEN_DB"'
from departures import departures
c = build()
q = []
c.set_trace_callback(q.append)
departures(c, "BBB", "2026-12-05")
c.set_trace_callback(None)
for sql in q:
    for row in c.execute("EXPLAIN QUERY PLAN " + sql):
        assert not row[3].startswith("SCAN") and "AUTOMATIC" not in row[3], (row[3], sql)
'
INDEXES='
import glob, sqlite3
c = sqlite3.connect(":memory:")
for p in sorted(glob.glob("migrations/*.sql")):
    c.executescript(open(p).read())
def cols(t):
    return [[r[2] for r in c.execute("PRAGMA index_info(%s)" % i[1])] for i in c.execute("PRAGMA index_list(%s)" % t)
            if not i[1].startswith("sqlite_autoindex")]
tr, bk = cols("trains"), cols("bookings")
assert any(x[:2] == ["from_station", "journey_date"] for x in tr), tr
assert any(x[:1] == ["train_id"] for x in bk), bk
assert len(tr) + len(bk) <= 2, (tr, bk)
'
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
TWO=$(printf 'departures.py\nmigrations/02_add_departures_indexes.sql')
check "on main, exactly 2 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 2 ] && [ "$(git rev-parse HEAD~1)" = "$BASE" ]'
check "new commit: departures.py + new migrations/02_add_departures_indexes.sql only; message has \"departures\"" '[ "$(git diff --name-only HEAD~1 HEAD | sort)" = "$TWO" ] && git diff --name-only --diff-filter=A HEAD~1 HEAD | grep -qx migrations/02_add_departures_indexes.sql && git log -1 --format=%B | grep -qi departures'
check "01 migration, db.py, measure.py, test file unchanged" 'git diff --quiet "$BASE" HEAD -- migrations/01_create_tables.sql db.py measure.py test_departures.py && git diff --quiet "$BASE" -- migrations/01_create_tables.sql db.py measure.py test_departures.py'
check "pytest passes at HEAD (3 tests)" 'pytest_at HEAD | grep -q "^3 passed"'
check "hidden data: right board (incl. 0-booking trains, empty station), at most 2 queries" 'py_at HEAD "$RESULTS"'
check "hidden data: no SCAN / AUTOMATIC index in any plan" 'py_at HEAD "$PLANS"'
check "indexes: trains (from_station, journey_date...) + bookings (train_id...), no more than 2" 'py_at HEAD "$INDEXES"'
summary
