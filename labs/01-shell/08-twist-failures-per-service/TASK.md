# 08 - Failures per service (Twist)

## Situation
`logs/access.log` has one request per line, fields separated by **single spaces**:
```
2026-10-25T10:00:09 service=orders method=POST status=500 2988ms
^ field 1           ^ field 2      ^ field 3   ^ field 4  ^ field 5
```
A request **failed** if its status is any 5xx (500, 502, 503, 504...). Your manager wants to know which
service failed most. There is no `reports` folder yet.

## Task
1. Create `reports/failures.txt`: for each service that had at least one failure, one line
   `COUNT service=NAME`, sorted by service name A-Z. Example of the shape (not the real numbers):
   ```
         4 service=alpha
         1 service=beta
   ```
   (Leading spaces before the count are fine - that is how `uniq -c` prints.)
2. Create `reports/top.txt` with just the **one** line from `failures.txt` with the highest count.

## Stop
- Don't change `logs/access.log`.

## Hints
- Step by step, looking at the output each time (press up-arrow to get the last command back and add one more `| ...`):
  filter failed lines -> keep only the service field -> sort -> count.
- `cut -d' ' -f2` keeps field 2 when fields are split by a space.
- `uniq -c` counts **neighbouring** identical lines. `sort -n` sorts numbers, `-r` reverses.
- Careful: `500ms` is a time, not a status.

## What will be checked
- `reports/failures.txt` (ignoring leading/extra spaces) is exactly the right counts, A-Z by service
- `reports/top.txt` is the line for the service with the most failures
- `logs/access.log` is unchanged
