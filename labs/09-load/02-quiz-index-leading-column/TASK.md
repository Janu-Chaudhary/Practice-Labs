# 09-load / 02 - The right composite index (leading column)  (Quiz-style)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add trains table and search queries
$ python3 plan.py
indexes on trains: []
search station+date: SCAN trains
search station only: SCAN trains
admin report (date): SCAN trains
```

## Situation
Tatkal opens at 10:00 and the search page is slow. It runs two queries thousands of times a minute
(see `railbook.py`):
- search by **station and date**: `WHERE from_station = ? AND journey_date = ?`
- search by **station only**: `WHERE from_station = ?`

`SCAN trains` means sqlite reads all 5000 rows for every search (Postgres calls it `Seq Scan`).
`SEARCH trains USING INDEX ...` means it jumps straight to the matching rows (Postgres: `Index Scan`).
The database is built the production way: every `migrations/*.sql` file is applied in name order.
`01_create_trains.sql` is already applied in production.

## Task
1. In the Files panel create `migrations/02_add_trains_index.sql` with **one** statement that creates
   a composite index named `idx_trains_station_date` on the two search columns, in the order that lets
   **both** searches use it. Save (Ctrl+S).
2. Run `python3 plan.py` and check both search lines say `SEARCH trains USING INDEX idx_trains_station_date`.
   Then save that output to a file: `python3 plan.py > plan.txt`
3. Run `pytest`: all 3 tests pass.
4. Make **one** commit that adds exactly `migrations/02_add_trains_index.sql` and `plan.txt`, message
   contains `index`.

## Stop
- Don't edit `01_create_trains.sql` (applied migrations are never changed), `railbook.py`, `plan.py`
  or the test file. Create exactly one index. No extra commits.
- The admin report (date only) is allowed to stay slow.

## What will be checked
- 2 commits; the new one adds only the migration file and `plan.txt`; message contains `index`
- applying the migrations gives exactly one index on `trains`: `idx_trains_station_date` with columns
  in the right order
- both search queries `SEARCH ... USING INDEX idx_trains_station_date`; `plan.txt` shows that
- `01_create_trains.sql` unchanged; pytest passes at HEAD
