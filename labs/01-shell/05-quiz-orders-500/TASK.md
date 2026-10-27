# 05 - Quiz 1 Q18, recreated (Quiz-style, 6 marks)

## Situation
`logs/access.log`
```
2026-09-28T09:00:03 service=orders method=GET status=200 11ms
2026-09-28T09:01:55 service=users method=GET status=200 9ms
2026-09-28T09:03:29 service=orders method=POST status=500 2987ms
2026-09-28T09:04:02 service=health method=GET status=200 1ms
2026-09-28T09:06:48 service=orders method=GET status=500 3104ms
```
`logs/access.log.1`
```
2026-09-27T10:00:01 service=orders method=GET status=200 14ms
2026-09-27T10:02:17 service=orders method=POST status=500 3021ms
2026-09-27T10:05:40 service=users method=GET status=500 88ms
2026-09-27T10:09:12 service=orders method=POST status=201 45ms
```

Context: The current folder has a folder called `logs`, holding two access logs:
- `logs/access.log.1`: yesterday's log (the older one)
- `logs/access.log`: today's log

Each line is one request: timestamp, `service=…`, `method=…`, `status=…` and the time it took.
There is no `reports` folder and no `logs/archive` folder yet.

## Task
1. Create `reports/orders-500.txt` holding every request to the `service=orders` that failed with
   `status=500`, from both logs. Yesterday's logs first, then today's logs.
2. Move (don't copy) `logs/access.log.1` into a new folder `logs/archive`, keeping its name.

## Stop
Leave `logs/access.log` where it is, and don't change either log file's contents.

## Hint (from the real paper)
- Use grep (for filter), `|` (pipe), `>` (for overwrite) and `>>` (append)
- use `--help` to know more about a command
- Example: `grep [PATTERN1] <file1> | grep [PATTERN2] <file2> > <file3>`

**Warning:** that example is misleading if copied literally. Think about which grep should get a file name
and which should read the pipe. And think about the order of the two steps.

## What will be checked
- `reports/orders-500.txt` has the expected content (exactly 3 lines, plain log lines, yesterday's first)
- `logs/archive/access.log.1` exists (with its original contents)
- `logs/access.log.1` is gone
- `logs/access.log` is still there and unchanged
