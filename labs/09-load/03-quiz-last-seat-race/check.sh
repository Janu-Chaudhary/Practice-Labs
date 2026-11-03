#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-load/03-quiz-last-seat-race"
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
# Hidden race: N users; whenever book_seat pauses, the next user runs a full booking inside the gap.
# Uses the checker's own table (no CHECK) so the code itself must be right.
RACE='
import sqlite3, booking
def db(cap, bk):
    c = sqlite3.connect(":memory:")
    c.execute("CREATE TABLE trains (id INTEGER PRIMARY KEY, train_no TEXT NOT NULL, capacity INTEGER NOT NULL, booked INTEGER NOT NULL DEFAULT 0)")
    c.execute("INSERT INTO trains VALUES (1, ?, ?, ?)", ("12124", cap, bk)); c.commit()
    return c
def crowd(c, n):
    orig = booking.pause; res = []; nxt = [0]
    def run_next():
        if nxt[0] < n:
            nxt[0] += 1
            res.append(booking.book_seat(c, 1))
    booking.pause = run_next
    try:
        while nxt[0] < n:
            run_next()
    finally:
        booking.pause = orig
    return sorted(res)
bk = lambda c: c.execute("SELECT booked FROM trains").fetchone()[0]
c = db(100, 99); assert crowd(c, 2) == [201, 409] and bk(c) == 100, "last seat"
c = db(3, 0);    assert crowd(c, 5) == [201, 201, 201, 409, 409] and bk(c) == 3, "5 users 3 seats"
c = db(100, 100); assert crowd(c, 10) == [409] * 10 and bk(c) == 100, "full train"
'
CHECKC='
import sqlite3
c = sqlite3.connect(":memory:")
c.executescript(open("schema.sql").read())
c.execute("INSERT INTO trains (id, train_no, capacity, booked) VALUES (1, ?, 10, 10)", ("x",))
c.execute("INSERT INTO trains (id, train_no, capacity, booked) VALUES (2, ?, 10, 3)", ("y",))
try:
    c.execute("UPDATE trains SET booked = 11 WHERE id = 1")
except sqlite3.IntegrityError:
    pass
else:
    raise SystemExit("booked > capacity was accepted")
'
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
TWO=$(printf 'booking.py\nschema.sql')
check "on main, exactly 3 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 3 ] && [ "$(git rev-parse HEAD~2)" = "$BASE" ]'
check "HEAD~1 changed only test_booking.py, message contains \"failing test\"" '[ "$(git diff --name-only HEAD~2 HEAD~1)" = test_booking.py ] && git log -1 --format=%B HEAD~1 | grep -qi "failing test"'
check "test_last_seat_two_users exists and uses two_users_at_once" 'git show HEAD:test_booking.py | grep -q "def test_last_seat_two_users" && git show HEAD:test_booking.py | grep -q "two_users_at_once("'
check "at HEAD~1 pytest FAILS (the test catches the race)" 'pytest_at HEAD~1 >/dev/null; [ $? -eq 1 ]'
check "HEAD changed exactly booking.py and schema.sql" '[ "$(git diff --name-only HEAD~1 HEAD | sort)" = "$TWO" ]'
check "race.py, db.py unchanged; old tests still there" 'git diff --quiet "$BASE" HEAD -- race.py db.py && git show HEAD:test_booking.py | grep -q "def test_free_seat_is_booked" && git show HEAD:test_booking.py | grep -q "def test_full_train_returns_409"'
check "booking.py uses UPDATE ... WHERE ... booked < capacity and checks rowcount" 'git show HEAD:booking.py | grep -qi "UPDATE trains" && git show HEAD:booking.py | grep -Eq "booked *< *capacity" && git show HEAD:booking.py | grep -q rowcount'
check "at HEAD pytest passes (at least 3 tests)" 'pytest_at HEAD | grep -Eq "^([3-9]|[1-9][0-9]+) passed"'
check "hidden races: last seat 1x201+1x409; 5 users/3 seats; full train stays full" 'py_at HEAD "$RACE"'
check "schema.sql: the database refuses booked > capacity (CHECK)" 'py_at HEAD "$CHECKC"'
summary
