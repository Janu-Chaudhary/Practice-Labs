#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
mkdir -p migrations

cat > migrations/01_create_trains.sql <<'EOF'
-- Applied to production on 2026-10-01. Never edit an applied migration: add a new file.
CREATE TABLE trains (
    id           INTEGER PRIMARY KEY,
    train_no     TEXT NOT NULL,
    from_station TEXT NOT NULL,
    to_station   TEXT NOT NULL,
    journey_date TEXT NOT NULL,
    capacity     INTEGER NOT NULL,
    booked       INTEGER NOT NULL DEFAULT 0
);
EOF

cat > railbook.py <<'EOF'
"""Build the RailBook DB the way production does: apply migrations/*.sql in name order, add data."""
import glob
import random
import sqlite3

# The two queries the Tatkal search page runs thousands of times a minute
SEARCH_STATION_DATE = "SELECT id, train_no, to_station FROM trains WHERE from_station = ? AND journey_date = ?"
SEARCH_STATION = "SELECT id, train_no, to_station FROM trains WHERE from_station = ?"
# A nightly admin report (runs once a day, nobody cares if it is slow)
REPORT_DATE = "SELECT id, train_no, to_station FROM trains WHERE journey_date = ?"

STATIONS = ["PUNE", "CSMT", "NDLS", "SBC", "HWH", "MAS", "ADI", "JP"]


def make_db():
    conn = sqlite3.connect(":memory:")
    for path in sorted(glob.glob("migrations/*.sql")):
        with open(path) as f:
            conn.executescript(f.read())
    rnd = random.Random(14)
    rows = [(i, str(12000 + i), rnd.choice(STATIONS), rnd.choice(STATIONS),
             "2026-11-%02d" % rnd.randint(1, 30), 100, rnd.randint(0, 100)) for i in range(1, 5001)]
    conn.executemany("INSERT INTO trains (id, train_no, from_station, to_station, journey_date, capacity, booked)"
                     " VALUES (?, ?, ?, ?, ?, ?, ?)", rows)
    conn.commit()
    return conn


def plan(conn, sql, params):
    """EXPLAIN QUERY PLAN: sqlite's version of Postgres EXPLAIN. Returns the plan lines."""
    return [row[3] for row in conn.execute("EXPLAIN QUERY PLAN " + sql, params)]
EOF

cat > plan.py <<'EOF'
"""Print how sqlite runs each search query.  SCAN = reads every row.  SEARCH ... USING INDEX = jumps."""
from railbook import REPORT_DATE, SEARCH_STATION, SEARCH_STATION_DATE, make_db, plan

conn = make_db()
print("indexes on trains:", [r[1] for r in conn.execute("PRAGMA index_list(trains)")])
for name, sql, params in [
    ("search station+date", SEARCH_STATION_DATE, ("PUNE", "2026-11-14")),
    ("search station only", SEARCH_STATION, ("PUNE",)),
    ("admin report (date)", REPORT_DATE, ("2026-11-14",)),
]:
    for line in plan(conn, sql, params):
        print("%-20s %s" % (name + ":", line))
EOF

cat > test_search_plan.py <<'EOF'
from railbook import SEARCH_STATION, SEARCH_STATION_DATE, make_db, plan


def test_station_and_date_search_uses_an_index():
    lines = plan(make_db(), SEARCH_STATION_DATE, ("PUNE", "2026-11-14"))
    assert any(l.startswith("SEARCH trains USING INDEX") for l in lines), lines


def test_station_only_search_uses_an_index():
    lines = plan(make_db(), SEARCH_STATION, ("PUNE",))
    assert any(l.startswith("SEARCH trains USING INDEX") for l in lines), lines


def test_search_still_returns_the_right_trains():
    conn = make_db()
    rows = conn.execute(SEARCH_STATION_DATE, ("PUNE", "2026-11-14")).fetchall()
    assert len(rows) == 22
EOF
git add . && git commit -q -m "Add trains table and search queries"
git rev-parse HEAD > .git/lab-base
banner "09-load/02-quiz-index-leading-column"
