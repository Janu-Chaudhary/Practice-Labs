# 09-load / 05 - The slow departures board: two problems at once  (Twist)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add departures board
$ python3 measure.py
rows on the board: 21
queries: 22   (x 30 ms each in production = 660 ms)
   SELECT id, train_no, to_station FROM trains ...
   SELECT count(*) FROM bookings ...
plans:
   SCAN trains
   USE TEMP B-TREE FOR ORDER BY
   SCAN bookings
$ pytest -q
.FF
```

## Situation
At 09:59 the departures board (`departures.py`) is the slowest page in RailBook. It has **two**
different problems, and fixing only one is not enough:
- too many **round trips**: 1 query for the trains + 1 count query per train (N+1);
- every query **reads whole tables** (`SCAN`): there is no index for what it filters / joins on.

`measure.py` shows both (query count and the `EXPLAIN QUERY PLAN` of every query it ran).
The DB is built from `migrations/*.sql` in name order (01 is already applied in production).
`test_departures.py` holds the targets: correct board, at most 2 queries, no `SCAN` (and no
`AUTOMATIC` index, which is sqlite building a throwaway index on every call).

## Task
1. `departures.py`: get the board with **one** query (or two), same result: same rows, same order
   (by train_no), trains with **0 bookings** must still appear with `booked: 0`.
2. Create `migrations/02_add_departures_indexes.sql` with the index(es) that remove every `SCAN`.
   Re-run `python3 measure.py` after each step and watch the numbers.
3. `pytest`: 3 passed. One commit with exactly those two files, message contains `departures`.

## Stop
- Don't edit `01_create_tables.sql`, `db.py`, `measure.py` or the test file. One new commit.
- Don't add indexes you don't need (each one slows every insert).

## What will be checked
- 2 commits; the new one changes exactly `departures.py` and adds `migrations/02_add_departures_indexes.sql`
- pytest passes at HEAD; 01 migration unchanged
- hidden data (other stations/dates, a station with no trains): same board as a reference query,
  at most 2 queries, no `SCAN`/`AUTOMATIC` in any plan
- the migrations create an index whose leading column is `trains.from_station` (with `journey_date`)
  and one led by `bookings.train_id`; at most 2 new indexes in total
