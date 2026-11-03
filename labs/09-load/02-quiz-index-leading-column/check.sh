#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-load/02-quiz-index-leading-column"
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
# Build the DB from HEAD's migrations with the checker's own code (not the student's railbook.py)
INDEX='
import glob, sqlite3
c = sqlite3.connect(":memory:")
for p in sorted(glob.glob("migrations/*.sql")):
    c.executescript(open(p).read())
idx = [r[1] for r in c.execute("PRAGMA index_list(trains)") if not r[1].startswith("sqlite_autoindex")]
assert idx == ["idx_trains_station_date"], idx
cols = [r[2] for r in c.execute("PRAGMA index_info(idx_trains_station_date)")]
assert cols == ["from_station", "journey_date"], cols
'
PLANS='
import glob, sqlite3
c = sqlite3.connect(":memory:")
for p in sorted(glob.glob("migrations/*.sql")):
    c.executescript(open(p).read())
c.executemany("INSERT INTO trains VALUES (?,?,?,?,?,?,?)",
              [(i, str(i), "S%d" % (i % 8), "T", "2026-11-%02d" % (i % 30 + 1), 100, 0) for i in range(1, 3001)])
for sql, a in [("SELECT id, train_no FROM trains WHERE from_station = ? AND journey_date = ?", ("S1", "2026-11-02")),
               ("SELECT id, train_no FROM trains WHERE from_station = ?", ("S1",)),
               ("SELECT * FROM trains WHERE journey_date = ? AND from_station = ?", ("2026-11-02", "S1"))]:
    lines = [r[3] for r in c.execute("EXPLAIN QUERY PLAN " + sql, a)]
    assert any(l.startswith("SEARCH trains USING INDEX idx_trains_station_date") for l in lines), (sql, lines)
'
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
NEW=$(printf 'migrations/02_add_trains_index.sql\nplan.txt')
check "on main, exactly 2 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 2 ] && [ "$(git rev-parse HEAD~1)" = "$BASE" ]'
check "new commit adds exactly migrations/02_add_trains_index.sql and plan.txt" '[ "$(git diff --name-only --diff-filter=A HEAD~1 HEAD | sort)" = "$NEW" ] && [ "$(git diff --name-only HEAD~1 HEAD | sort)" = "$NEW" ]'
check "commit message contains \"index\"" 'git log -1 --format=%B | grep -qi index'
check "01_create_trains.sql, railbook.py, plan.py, test file unchanged" 'git diff --quiet "$BASE" -- migrations/01_create_trains.sql railbook.py plan.py test_search_plan.py && git diff --quiet "$BASE" HEAD -- migrations/01_create_trains.sql railbook.py plan.py test_search_plan.py'
check "migrations create exactly one index: idx_trains_station_date (from_station, journey_date)" 'py_at HEAD "$INDEX"'
if (cd "$WORK" 2>/dev/null && py_at HEAD "$INDEX" 2>/dev/null | grep -q "'journey_date', 'from_station'"); then
  hint "column order: both hot queries filter on from_station, so it must be the LEADING (first) column"; fi
check "station+date AND station-only searches: SEARCH ... USING INDEX idx_trains_station_date" 'py_at HEAD "$PLANS"'
check "plan.txt (committed) shows both searches using idx_trains_station_date" 'git show HEAD:plan.txt | grep -q "^search station+date: SEARCH trains USING INDEX idx_trains_station_date" && git show HEAD:plan.txt | grep -q "^search station only: SEARCH trains USING INDEX idx_trains_station_date (from_station=?)"'
check "pytest passes at HEAD (3 tests)" 'pytest_at HEAD | grep -q "^3 passed"'
summary
