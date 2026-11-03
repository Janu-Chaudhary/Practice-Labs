# Solution - 03-quiz-last-seat-race

## Step 1: the failing test
In the Files panel open `test_booking.py` and make it read:
```python
from booking import book_seat
from db import booked, make_db
from race import two_users_at_once


def test_free_seat_is_booked():
    conn = make_db(capacity=100, booked=10)
    assert book_seat(conn, 1) == 201
    assert booked(conn) == 11


def test_full_train_returns_409():
    conn = make_db(capacity=100, booked=100)
    assert book_seat(conn, 1) == 409
    assert booked(conn) == 100


def test_last_seat_two_users():
    conn = make_db(capacity=100, booked=99)
    results = two_users_at_once(conn, 1)
    assert sorted(results) == [201, 409]
    assert booked(conn) == 100
```
Save (Ctrl+S). Then:
```bash
pytest          # 1 failed, 2 passed:  assert [201, 201] == [201, 409]   (both users "got" the seat)
git add test_booking.py
git commit -m "Add failing test: two users race for the last seat"
```

## Step 2: the fix
In the Files panel open `booking.py` and make `book_seat` read (keep `pause` as it is):
```python
def book_seat(conn, train_id):
    """Book one seat on a train. Returns 201 if you got a seat, 409 if the train is full."""
    cur = conn.execute(
        "UPDATE trains SET booked = booked + 1 WHERE id = ? AND booked < capacity",
        (train_id,),
    )                                               # check AND act in ONE statement
    conn.commit()
    if cur.rowcount == 0:                           # 0 rows changed = no seat left
        return 409
    return 201
```
Open `schema.sql` and add the CHECK line:
```sql
CREATE TABLE trains (
    id       INTEGER PRIMARY KEY,
    train_no TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    booked   INTEGER NOT NULL DEFAULT 0,
    CHECK (booked <= capacity)
);
```
Save both. Then:
```bash
pytest          # 3 passed
git add booking.py schema.sql
git commit -m "Fix last-seat race: conditional UPDATE, 409 when full, CHECK booked <= capacity"
cd .. && ./check.sh
```

Why:
- The bug is the **gap** between the read (check) and the write (act). Another request can run in
  that gap. Putting the condition `booked < capacity` inside the UPDATE's WHERE makes check and act
  one statement: the database does them together, so only one request can take seat 100.
- `rowcount` = how many rows the UPDATE changed: 1 = you got the seat (201), 0 = full (409 Conflict,
  an expected business answer, not a 500 crash). Postgres: `... RETURNING booked`, 0 rows = full.
- `CHECK (booked <= capacity)` is the **safety net**: if some other code path has the bug, the
  database refuses the row instead of overselling. It is not the main fix: alone it turns an
  oversell into an error (500), not a friendly 409.
- In Postgres you would add it with a migration:
  `ALTER TABLE trains ADD CONSTRAINT booked_le_capacity CHECK (booked <= capacity);`
  Fix 2 (lock the row: `SELECT ... FOR UPDATE` inside BEGIN/COMMIT) also works when the logic
  needs several statements.

Common wrong attempts:
- Wrapping the old read + write in BEGIN/COMMIT: a transaction is all-or-nothing, it does NOT stop
  two requests reading the same count first.
- Only adding the CHECK: user A's UPDATE now raises `sqlite3.IntegrityError` (a crash), the test
  still fails. You need the conditional UPDATE for the 409.
- `WHERE id = ? AND booked <= capacity`: lets booked go from 100 to 101. It must be `<`.
- Keeping the old SELECT + `if booked >= capacity` before the new UPDATE: still works (the UPDATE
  decides), but it is a wasted round trip; returning 201 without checking rowcount is wrong.
- Fixing booking.py before committing the test, then `git add .` -> the fix lands in the test commit
  and pytest at HEAD~1 is not red.
- Forgetting `from race import two_users_at_once` -> `NameError`: pytest shows it as failed at
  HEAD~1 too, but the check also wants the test to pass after the fix.
