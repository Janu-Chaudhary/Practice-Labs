#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore

cat > schema.sql <<'EOF'
CREATE TABLE trains (
    id       INTEGER PRIMARY KEY,
    train_no TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    booked   INTEGER NOT NULL DEFAULT 0
);
EOF

cat > db.py <<'EOF'
"""Fresh in-memory RailBook DB built from schema.sql, with train 1 (12124)."""
import sqlite3


def make_db(capacity=100, booked=0):
    conn = sqlite3.connect(":memory:")
    with open("schema.sql") as f:
        conn.executescript(f.read())
    conn.execute("INSERT INTO trains (id, train_no, capacity, booked) VALUES (1, '12124', ?, ?)",
                 (capacity, booked))
    conn.commit()
    return conn


def booked(conn, train_id=1):
    return conn.execute("SELECT booked FROM trains WHERE id = ?", (train_id,)).fetchone()[0]
EOF

cat > booking.py <<'EOF'
def pause():
    """The gap between reading and writing. Does nothing in production.
    Tests replace it to let a second user run right here (see race.py)."""


def book_seat(conn, train_id):
    """Book one seat on a train. Returns 201 if you got a seat, 409 if the train is full."""
    booked, capacity = conn.execute(
        "SELECT booked, capacity FROM trains WHERE id = ?", (train_id,)
    ).fetchone()                                    # CHECK: is there a seat?
    if booked >= capacity:
        return 409
    pause()                                         # <- danger window
    conn.execute("UPDATE trains SET booked = booked + 1 WHERE id = ?", (train_id,))
    conn.commit()                                   # ACT: take it
    return 201
EOF

cat > race.py <<'EOF'
"""Run two users at "the same moment", the same way every time (no threads, no luck needed).

User A calls book_seat. If book_seat calls pause() (the gap between its check and its write),
user B runs a complete booking inside that gap. Then A continues. If book_seat has no gap,
B simply books right after A.  Returns [A's status, B's status].
"""
import booking


def two_users_at_once(conn, train_id):
    original = booking.pause
    results = {}

    def user_b_runs_now():
        booking.pause = original          # B itself must not pause again
        results["B"] = booking.book_seat(conn, train_id)

    booking.pause = user_b_runs_now
    try:
        results["A"] = booking.book_seat(conn, train_id)
    finally:
        booking.pause = original
    if "B" not in results:
        results["B"] = booking.book_seat(conn, train_id)
    return [results["A"], results["B"]]
EOF

cat > test_booking.py <<'EOF'
from booking import book_seat
from db import booked, make_db


def test_free_seat_is_booked():
    conn = make_db(capacity=100, booked=10)
    assert book_seat(conn, 1) == 201
    assert booked(conn) == 11


def test_full_train_returns_409():
    conn = make_db(capacity=100, booked=100)
    assert book_seat(conn, 1) == 409
    assert booked(conn) == 100
EOF
git add . && git commit -q -m "Add seat booking"
git rev-parse HEAD > .git/lab-base
banner "09-load/03-quiz-last-seat-race"
