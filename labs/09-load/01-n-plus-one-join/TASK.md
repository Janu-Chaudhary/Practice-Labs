# 09-load / 01 - Kill an N+1 with one JOIN  (Drill)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add my-bookings page
$ pytest -q
..F                                                         [100%]
FAILED test_bookings.py::test_at_most_two_queries - assert 6 <= 2
```

## Situation
RailBook's "My bookings" page is fine on a laptop (DB 1 ms away) and slow in production (DB ~30 ms away).
`bookings.py` runs **1** query for the user's bookings, then **1 more query per booking** to fetch the
train. That is the **N+1** pattern: 5 bookings = 6 round trips; 50 bookings = 51 trips x 30 ms = 1.5 s.

`test_at_most_two_queries` counts the SQL statements with `conn.set_trace_callback(...)` (sqlite calls
the function once for every statement it runs). Run `pytest -s` to see the 6 queries printed.

## Task
1. In the Files panel open `bookings.py` and rewrite `list_bookings_with_trains` so it runs **one**
   query: `bookings JOIN trains ON trains.id = bookings.train_id`, filtered by `user_id`, ordered by
   the booking id. Keep the returned list exactly the same (same keys, same order). Save (Ctrl+S).
2. Run `pytest -v`: all 3 tests pass.
3. Commit only `bookings.py` with a message containing `N+1`.

## Stop
- Don't edit `test_bookings.py` or `db.py`. Exactly one new commit on `main`, don't push.

## What will be checked
- 2 commits on main; the new one changes only `bookings.py`; message contains `N+1`
- pytest passes at HEAD (3 tests); test file and db.py unchanged
- on a bigger hidden database (a user with 20 bookings) your function runs at most 2 queries and
  returns exactly the right list (same order); a user with no bookings gets `[]`
