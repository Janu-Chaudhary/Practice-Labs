# Solution - 09 dated folders + slow requests

```bash
ls incoming
mkdir -p archive/2026-10-24 archive/2026-10-25 reports
#   -p creates archive/ as well; one mkdir can make several folders
mv incoming/*2026-10-24* archive/2026-10-24/
#   the shell expands * to every matching name BEFORE mv runs, so mv gets 2 files + a folder
mv incoming/*2026-10-25* archive/2026-10-25/
ls -R archive incoming
grep -hE '[0-9]{4,}ms' archive/*/*.log | sort > reports/slow.txt
#   -h no file names, -E so {4,} works; 4+ digits then "ms" = 1000ms or more; sort = by timestamp
cat reports/slow.txt
```

Expected `reports/slow.txt`:
```
2026-10-24T09:01:00 query=select-orders 1200ms
2026-10-24T09:05:00 service=orders method=POST status=500 2500ms
2026-10-25T09:59:00 query=select-search 3400ms
2026-10-25T10:00:00 service=orders method=GET status=200 1000ms
2026-10-25T10:10:00 service=search method=GET status=200 10500ms
```

Equivalent filters: `grep -h '[0-9][0-9][0-9][0-9]ms'` (basic grep, no -E), or anchor to the line end:
`grep -hE ' [0-9]{4,}ms$'`. Why sorting works: timestamps are written biggest unit first
(year-month-dayThour:min:sec), so text order = time order.

## Common wrong attempts
- `mv incoming/*2026-10-24* archive/2026-10-24` **before** creating the folder -> with 2 sources:
  `mv: target 'archive/2026-10-24': No such file or directory`. With 1 source it would silently rename the file.
- `mv incoming/* archive/2026-10-24/` -> moves readme.txt and the 10-25 logs too.
- `grep -E '[0-9]{3,}ms'` -> catches `999ms`. `grep '[0-9]{4,}ms'` without `-E` -> `{4,}` is taken literally, nothing matches.
- No `sort` -> lines come file by file (app before db), not in time order.
- `grep -E ... archive/*/*.log` without `-h` -> each line prefixed with `archive/2026-10-24/app-2026-10-24.log:`.
