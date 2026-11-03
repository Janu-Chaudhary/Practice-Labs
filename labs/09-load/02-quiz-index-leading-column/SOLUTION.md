# Solution - 02-quiz-index-leading-column

In the Files panel: **+ New file**, name `migrations/02_add_trains_index.sql`, content:
```sql
CREATE INDEX idx_trains_station_date ON trains (from_station, journey_date);
```
Save with Ctrl+S. Then:
```bash
python3 plan.py
# indexes on trains: ['idx_trains_station_date']
# search station+date: SEARCH trains USING INDEX idx_trains_station_date (from_station=? AND journey_date=?)
# search station only: SEARCH trains USING INDEX idx_trains_station_date (from_station=?)
# admin report (date): SCAN trains
python3 plan.py > plan.txt       # > sends the output into the file instead of the screen
pytest                           # 3 passed
git add migrations/02_add_trains_index.sql plan.txt
git commit -m "Add station+date index for Tatkal search"
cd .. && ./check.sh
```

Why:
- A composite index is sorted by the **first** column, then by the second inside each first value
  (a phone book: surname, then first name). A search on the first column alone can use it; a search
  on the second column alone cannot (like finding everyone named "Ravi" in a phone book).
- Both hot queries filter on `from_station`, so it goes **first**. The date-only report still says
  `SCAN trains`: that is the leading-column rule, and it is fine (it runs once a night). If it mattered
  you would add a second index on `journey_date`, paying for it on every insert/update.
- A new migration file, never an edit to `01_...`: production already applied 01 (a tool like
  Flyway would also refuse a changed checksum).

Common wrong attempts:
- `ON trains (journey_date, from_station)` -> station+date searches use it, but `search station only`
  stays `SCAN trains` and `test_station_only_search_uses_an_index` fails. Order matters.
- Two single-column indexes, or one on `from_station` only -> not what was asked (exactly one
  composite index); also every extra index slows every write.
- Putting the CREATE INDEX into `01_create_trains.sql` -> changes an applied migration.
- `python3 plan.py > plan.txt` BEFORE creating the index -> plan.txt shows SCAN.
- `git add .` -> fine here (only the 2 new files are untracked), but check `git status` first.
- In Postgres on a live table you would write `CREATE INDEX CONCURRENTLY` (no write blocking),
  which cannot run inside a transaction. sqlite has no CONCURRENTLY.
