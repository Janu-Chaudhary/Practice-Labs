# 09 - Sort logs into dated folders, collect slow requests (Twist)

## Situation
The folder `incoming` holds:
```
app-2026-10-24.log  app-2026-10-25.log  db-2026-10-24.log  db-2026-10-25.log  readme.txt
```
Every log line **starts with a timestamp** and **ends with the time taken**, like `1200ms`.
There is no `archive` folder and no `reports` folder yet.

## Task
1. Reorganise: move every log into `archive/<date>/` by the date in its name, keeping its name:
   ```
   archive/2026-10-24/app-2026-10-24.log   archive/2026-10-24/db-2026-10-24.log
   archive/2026-10-25/app-2026-10-25.log   archive/2026-10-25/db-2026-10-25.log
   ```
   `incoming/readme.txt` stays where it is.
2. Create `reports/slow.txt`: every line, from all four logs, that took **1000ms or more**,
   sorted by time, **oldest first**. Plain log lines (no file names).

## Stop
- Don't change any log's contents. Don't touch `incoming/readme.txt`.

## Hints
- `*` in a file name means "any text": `incoming/*2026-10-24*` matches every file with that date. Try `ls incoming/*2026-10-24*` first to see what it matches.
- "1000ms or more" = at least **4 digits** before `ms`. In `grep -E`, `[0-9]` is one digit and `{4,}` means "4 or more of the thing before".
- Lines start with a timestamp, so a plain `sort` puts them in time order.
- Do the steps in an order that makes the paths easy. After moving, the logs are in `archive/*/`.

## What will be checked
- the four logs are in the right `archive/<date>/` folders, unchanged
- no `.log` file is left in `incoming`, and `incoming/readme.txt` is still there
- `reports/slow.txt` has exactly the 5 expected lines in time order
