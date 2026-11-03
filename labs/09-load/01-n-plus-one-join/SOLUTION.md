# Solution - 01-n-plus-one-join

See the problem first:
```bash
pytest -s -k two_queries     # prints 1 bookings query + 5 trains queries, then: assert 6 <= 2
```
In the Files panel open `bookings.py` and make it read:
```python
def list_bookings_with_trains(conn, user_id):
    """My bookings page: every booking of this user (oldest first) with its train."""
    rows = conn.execute(
        "SELECT b.pnr, t.train_no, t.from_station, t.to_station "
        "FROM bookings b JOIN trains t ON t.id = b.train_id "
        "WHERE b.user_id = ? ORDER BY b.id",
        (user_id,),
    ).fetchall()                                                   # 1 query, whatever N is
    return [{"pnr": pnr, "train_no": no, "from": f, "to": to} for pnr, no, f, to in rows]
```
Save with Ctrl+S. Then:
```bash
pytest -v                    # 3 passed
git add bookings.py
git commit -m "Fix N+1 on my-bookings page: one JOIN instead of a query per booking"
cd .. && ./check.sh
```

Why:
- The cost of N+1 is **round trips x latency**, not slow SQL. Each small query is fast; 51 of them
  across a 30 ms network are not. The JOIN asks the database for everything in **one** trip.
- `ORDER BY b.id` keeps the same order as before (the old code ordered the bookings by id).
- Another valid fix with 2 queries: get the bookings, then
  `SELECT ... FROM trains WHERE id IN (?, ?, ...)` with all the train ids (Postgres: `= ANY($1)`).

Common wrong attempts:
- Adding an index on `trains.id` / `bookings.train_id`: each query gets faster but there are still
  1 + N round trips. An index does not fix N+1.
- Forgetting `ORDER BY b.id`: the list may come back in another order -> the equality test fails.
- `SELECT *` with a JOIN then `row[1]`, `row[2]`...: the column positions change (both tables'
  columns are in the row), so you put the wrong values in the dict.
- Moving the loop into a helper function that still queries per booking: the count is still 6.
- `git commit -am` after also touching the test file -> the commit changes 2 files.
