#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
mkdir -p migrations

cat > migrations/01_create_tables.sql <<'EOF'
-- Applied to production. Never edit an applied migration: add a new file.
CREATE TABLE trains (
    id           INTEGER PRIMARY KEY,
    train_no     TEXT NOT NULL,
    from_station TEXT NOT NULL,
    to_station   TEXT NOT NULL,
    journey_date TEXT NOT NULL
);
CREATE TABLE bookings (
    id       INTEGER PRIMARY KEY,
    train_id INTEGER NOT NULL REFERENCES trains(id),
    pnr      TEXT NOT NULL
);
EOF

cat > db.py <<'EOF'
"""RailBook DB in memory: apply migrations/*.sql in name order, then add the same data every time."""
import glob
import random
import sqlite3

STATIONS = ["PUNE", "CSMT", "NDLS", "SBC", "HWH", "MAS", "ADI", "JP"]


def make_db():
    conn = sqlite3.connect(":memory:")
    for path in sorted(glob.glob("migrations/*.sql")):
        with open(path) as f:
            conn.executescript(f.read())
    rnd = random.Random(10)
    trains = []
    for i in range(1, 4001):
        frm = rnd.choice(STATIONS)
        to = rnd.choice([s for s in STATIONS if s != frm])
        trains.append((i, str(11000 + i), frm, to, "2026-11-%02d" % rnd.randint(1, 30)))
    conn.executemany("INSERT INTO trains (id, train_no, from_station, to_station, journey_date)"
                     " VALUES (?, ?, ?, ?, ?)", trains)
    bookings = [(j, rnd.randint(1, 4000), "45218%05d" % j) for j in range(1, 12001)]
    conn.executemany("INSERT INTO bookings (id, train_id, pnr) VALUES (?, ?, ?)", bookings)
    conn.commit()
    return conn


def run_and_trace(conn, fn, *args):
    """Call fn(conn, *args) and return (its result, list of SQL statements it ran)."""
    statements = []
    conn.set_trace_callback(statements.append)   # sqlite calls this once per statement
    try:
        result = fn(conn, *args)
    finally:
        conn.set_trace_callback(None)
    return result, statements


def plan(conn, sql):
    """EXPLAIN QUERY PLAN lines. SCAN = reads the whole table; SEARCH ... USING INDEX = jumps."""
    return [row[3] for row in conn.execute("EXPLAIN QUERY PLAN " + sql)]
EOF

cat > departures.py <<'EOF'
def departures(conn, station, date):
    """Departures board: trains leaving `station` on `date`, by train_no, with seats booked."""
    trains = conn.execute(
        "SELECT id, train_no, to_station FROM trains"
        " WHERE from_station = ? AND journey_date = ? ORDER BY train_no",
        (station, date),
    ).fetchall()
    board = []
    for train_id, train_no, to_station in trains:
        n = conn.execute(
            "SELECT count(*) FROM bookings WHERE train_id = ?", (train_id,)
        ).fetchone()[0]
        board.append({"train_no": train_no, "to": to_station, "booked": n})
    return board
EOF

cat > measure.py <<'EOF'
"""How the departures board talks to the DB.  Run: python3 measure.py"""
from db import make_db, plan, run_and_trace
from departures import departures

conn = make_db()
board, statements = run_and_trace(conn, departures, "PUNE", "2026-11-14")
print("rows on the board:", len(board))
print("queries:", len(statements), "  (x 30 ms each in production = %d ms)" % (len(statements) * 30))
for sql in dict.fromkeys(s.split(" WHERE ")[0] + " ..." for s in statements):
    print("  ", sql)
print("plans:")
seen = set()
for sql in statements:
    for line in plan(conn, sql):
        if line not in seen:
            seen.add(line)
            print("  ", line)
EOF
cat > test_departures.py <<'EOF'
from db import make_db, plan, run_and_trace
from departures import departures


def board():
    conn = make_db()
    result, statements = run_and_trace(conn, departures, "PUNE", "2026-11-14")
    return conn, result, statements


def test_board_is_correct():
    _, b, _ = board()
    assert len(b) == 21
    assert b[0] == {"train_no": "11081", "to": "NDLS", "booked": 4}
    assert b[-1] == {"train_no": "14713", "to": "SBC", "booked": 3}
    assert {"train_no": "12051", "to": "NDLS", "booked": 0} in b     # nobody booked it yet
    assert sum(row["booked"] for row in b) == 55
    assert [row["train_no"] for row in b] == sorted(row["train_no"] for row in b)


def test_at_most_two_queries():
    _, _, statements = board()
    assert len(statements) <= 2, statements[:3]


def test_no_full_table_scans():
    conn, _, statements = board()
    for sql in statements:
        for line in plan(conn, sql):
            assert not line.startswith("SCAN"), (line, sql)
            assert "AUTOMATIC" not in line, (line, sql)   # sqlite building a throwaway index
EOF
git add . && git commit -q -m "Add departures board"
git rev-parse HEAD > .git/lab-base
banner "09-load/05-twist-slow-departures"
