# Solution - 05-twist-slow-departures

## Step 1: one query instead of 1 + N
In the Files panel open `departures.py` and make it read:
```python
def departures(conn, station, date):
    """Departures board: trains leaving `station` on `date`, by train_no, with seats booked."""
    rows = conn.execute(
        "SELECT t.train_no, t.to_station, count(b.id)"
        " FROM trains t LEFT JOIN bookings b ON b.train_id = t.id"
        " WHERE t.from_station = ? AND t.journey_date = ?"
        " GROUP BY t.id ORDER BY t.train_no",
        (station, date),
    ).fetchall()
    return [{"train_no": no, "to": to, "booked": n} for no, to, n in rows]
```
Save, then:
```bash
python3 measure.py
# queries: 1
# plans:  SCAN t / BLOOM FILTER ON b ... / SEARCH b USING AUTOMATIC COVERING INDEX (train_id=?) LEFT-JOIN / ...
pytest -q          # 2 passed, 1 failed (test_no_full_table_scans)
```

## Step 2: the indexes
**+ New file** `migrations/02_add_departures_indexes.sql`:
```sql
CREATE INDEX idx_trains_station_date ON trains (from_station, journey_date);
CREATE INDEX idx_bookings_train ON bookings (train_id);
```
Save, then:
```bash
python3 measure.py
# queries: 1
#    SEARCH t USING INDEX idx_trains_station_date (from_station=? AND journey_date=?)
#    SEARCH b USING COVERING INDEX idx_bookings_train (train_id=?) LEFT-JOIN
#    USE TEMP B-TREE FOR ORDER BY
pytest -q          # 3 passed
git add departures.py migrations/02_add_departures_indexes.sql
git commit -m "Speed up departures board: one JOIN query + station/date and train_id indexes"
cd .. && ./check.sh
```

Why:
- N+1 and missing indexes are **different** problems. The JOIN removes round trips (22 -> 1);
  the indexes remove full reads inside the database. Production needs both.
- After adding only the trains index, the plan shows `SCAN b LEFT-JOIN`: for each train the
  JOIN reads all 12000 bookings. The join column `bookings.train_id` needs its own index. Join
  columns (foreign keys) are a classic missing index; Postgres does NOT index them for you.
- `LEFT JOIN` + `count(b.id)`: a train with no bookings still gets a row, and `count(b.id)`
  counts only real bookings (NULL is not counted) -> 0.
- `ORDER BY t.train_no` keeps the board in the same order. `USE TEMP B-TREE FOR ORDER BY` is a
  small sort of ~20 rows, not a table scan; it is fine.
- A 2-query version also passes: trains query, then
  `SELECT train_id, count(*) FROM bookings WHERE train_id IN (?, ?, ...) GROUP BY train_id`.

Common wrong attempts:
- `JOIN` (inner) instead of `LEFT JOIN` -> train 12051 (0 bookings) disappears from the board.
- `count(*)` with the LEFT JOIN -> trains with no bookings show `booked: 1` (the row of NULLs counts).
- Only the indexes, keeping the loop -> plans are fine but still 22 queries (22 x 30 ms).
- Only the JOIN -> 1 query, but `SCAN t` (and an AUTOMATIC index on bookings built every call).
- Only the trains index -> `SCAN b LEFT-JOIN`. Only the bookings index -> `SCAN t`.
- Index `(journey_date, from_station)` -> also works for this one query (both columns are `=`),
  but the station-only search elsewhere in RailBook could not use it; the check wants
  from_station leading (lab 02's rule).
- Putting the indexes into `01_create_tables.sql` -> editing an applied migration.
