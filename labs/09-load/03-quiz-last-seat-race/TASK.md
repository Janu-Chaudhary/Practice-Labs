# 09-load / 03 - Two users, one last seat  (Quiz-style)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add seat booking
$ pytest -q
2 passed
```

## Situation
Train 12124 has `capacity = 100` and `booked = 99`. At 10:00:00 two people press "Book" together.
`book_seat()` in `booking.py` does **check-then-act**: it reads `booked`, decides there is a seat,
then writes. Both requests read 99 before either writes, so both get 201 and `booked` ends at 101:
2 bookings, 1 seat. The tests are green because they send one request at a time.

`race.py` gives you `two_users_at_once(conn, train_id)`: it runs user B inside user A's gap (the
`pause()` call), the same way every time, and returns `[A's status, B's status]`.

## Task
1. In `test_booking.py` add a test named `test_last_seat_two_users`: make a DB with capacity 100 and
   booked 99 (`make_db(capacity=100, booked=99)`), call `two_users_at_once(conn, 1)`, then assert that
   the sorted statuses are `[201, 409]` and `booked(conn) == 100`.
   Run `pytest`: the new test FAILS. Commit **only** the test file, message contains `failing test`.
2. Fix the race (two files, one commit):
   - `booking.py`: replace the read-then-write with **one** conditional
     `UPDATE trains SET booked = booked + 1 WHERE id = ? AND booked < capacity`, commit, and return
     **409** when no row was changed (`cursor.rowcount == 0`), else 201.
   - `schema.sql`: add the safety net `CHECK (booked <= capacity)` to the `trains` table.
   Run `pytest`: all 3 pass. Commit `booking.py` and `schema.sql` together.

## Stop
- Don't change `race.py`, `db.py` or the 2 existing tests. Exactly 2 new commits, don't push.

## What will be checked
- 3 commits; HEAD~1 = only `test_booking.py`, message has "failing test", pytest FAILS there
- HEAD = only `booking.py` + `schema.sql`; pytest passes (at least 3 tests)
- your test uses `two_users_at_once`; booking.py has the conditional `booked < capacity` UPDATE
- hidden race tests: last seat -> exactly one 201 and one 409, booked = 100; 5 users for 3 seats
  -> 3 x 201, 2 x 409; a full train never goes over capacity
- the DB itself refuses `booked > capacity` (the CHECK constraint)
