#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore

cat > db.py <<'EOF'
"""A small RailBook database in memory (sqlite3). Each call gives a fresh copy."""
import sqlite3

SCHEMA = """
CREATE TABLE trains (
    id           INTEGER PRIMARY KEY,
    train_no     TEXT NOT NULL,
    from_station TEXT NOT NULL,
    to_station   TEXT NOT NULL
);
CREATE TABLE bookings (
    id       INTEGER PRIMARY KEY,
    user_id  INTEGER NOT NULL,
    pnr      TEXT NOT NULL,
    train_id INTEGER NOT NULL REFERENCES trains(id)
);
"""

TRAINS = [
    (1, "12124", "PUNE", "CSMT"),
    (2, "12951", "MMCT", "NDLS"),
    (3, "12628", "NDLS", "SBC"),
    (4, "22691", "SBC", "NZM"),
    (5, "12301", "HWH", "NDLS"),
]

BOOKINGS = [
    (1, 7, "4521873390", 1),
    (2, 8, "4521873391", 2),
    (3, 7, "4521873392", 3),
    (4, 7, "4521873393", 1),
    (5, 9, "4521873394", 5),
    (6, 7, "4521873395", 4),
    (7, 7, "4521873396", 5),
]


def make_db():
    conn = sqlite3.connect(":memory:")
    conn.executescript(SCHEMA)
    conn.executemany("INSERT INTO trains VALUES (?, ?, ?, ?)", TRAINS)
    conn.executemany("INSERT INTO bookings VALUES (?, ?, ?, ?)", BOOKINGS)
    conn.commit()
    return conn
EOF

cat > bookings.py <<'EOF'
def list_bookings_with_trains(conn, user_id):
    """My bookings page: every booking of this user (oldest first) with its train."""
    rows = conn.execute(
        "SELECT id, pnr, train_id FROM bookings WHERE user_id = ? ORDER BY id",
        (user_id,),
    ).fetchall()                                                   # 1 query
    result = []
    for booking_id, pnr, train_id in rows:
        train = conn.execute(
            "SELECT train_no, from_station, to_station FROM trains WHERE id = ?",
            (train_id,),
        ).fetchone()                                               # + 1 query PER booking
        result.append({"pnr": pnr, "train_no": train[0], "from": train[1], "to": train[2]})
    return result
EOF

cat > test_bookings.py <<'EOF'
from bookings import list_bookings_with_trains
from db import make_db


def test_returns_every_booking_with_its_train():
    conn = make_db()
    assert list_bookings_with_trains(conn, 7) == [
        {"pnr": "4521873390", "train_no": "12124", "from": "PUNE", "to": "CSMT"},
        {"pnr": "4521873392", "train_no": "12628", "from": "NDLS", "to": "SBC"},
        {"pnr": "4521873393", "train_no": "12124", "from": "PUNE", "to": "CSMT"},
        {"pnr": "4521873395", "train_no": "22691", "from": "SBC", "to": "NZM"},
        {"pnr": "4521873396", "train_no": "12301", "from": "HWH", "to": "NDLS"},
    ]


def test_user_without_bookings_gets_empty_list():
    assert list_bookings_with_trains(make_db(), 42) == []


def test_at_most_two_queries():
    conn = make_db()
    queries = []
    conn.set_trace_callback(queries.append)    # sqlite calls this once per SQL statement
    list_bookings_with_trains(conn, 7)
    conn.set_trace_callback(None)
    print("\n".join(queries))                  # see them with: pytest -s
    assert len(queries) <= 2
EOF
git add . && git commit -q -m "Add my-bookings page"
git rev-parse HEAD > .git/lab-base
banner "09-load/01-n-plus-one-join"
