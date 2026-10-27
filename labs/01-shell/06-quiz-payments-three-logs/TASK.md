# 06 - Payments outage across three logs (Quiz-style, 6 marks)

## Situation
The current folder has a folder `logs` with three rotated logs:

- `logs/app.log.2`: the log from **two days ago** (oldest)
- `logs/app.log.1`: **yesterday's** log
- `logs/app.log`: **today's** log

Each line: timestamp, `service=…`, `method=…`, `status=…` and the time it took (e.g. `503ms`).
There is no `reports` folder and no `logs/archive` folder yet. Look at the logs with `cat` first.

## Task
1. Create `reports/payments-503.txt` holding every request to `service=payments` that failed with
   `status=503`, from all three logs, **oldest log first** (two days ago, then yesterday, then today).
2. Move both older logs (`app.log.2` and `app.log.1`) into a new folder `logs/archive/2026-10`, keeping their names.

## Stop
- Leave `logs/app.log` where it is.
- Don't change any log's contents.

## Hints
- A request that *took* 503ms is not a request that *failed* with 503. Make your pattern exact.
- One `mkdir` option creates `logs/archive` and `logs/archive/2026-10` together.
- `mv` can take several sources if the last argument is a folder.

## What will be checked
- `reports/payments-503.txt` has exactly the expected 4 lines, oldest first, no file names
- `logs/archive/2026-10/app.log.2` and `logs/archive/2026-10/app.log.1` exist, unchanged
- `logs/app.log.2` and `logs/app.log.1` are gone
- `logs/app.log` is still in place and unchanged
