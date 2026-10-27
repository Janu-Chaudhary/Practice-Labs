# Solution - 05 Quiz 1 Q18

```bash
mkdir reports
#   > can create a FILE but never a folder; without this: "reports/orders-500.txt: No such file or directory"
grep 'service=orders' logs/access.log.1 | grep 'status=500' > reports/orders-500.txt
#   yesterday first. The 1st grep reads the file, the 2nd reads the pipe (AND). > creates the report.
grep 'service=orders' logs/access.log | grep 'status=500' >> reports/orders-500.txt
#   today second. >> APPENDS, so yesterday's line stays on top.
cat reports/orders-500.txt
#   check: 3 lines, 09-27 first
mkdir logs/archive
#   mv will not create the folder for you
mv logs/access.log.1 logs/archive/
#   moving into an existing folder keeps the name -> logs/archive/access.log.1
ls -R logs
```

Shorter version of the grep part (one command, same result):
```bash
grep -h 'service=orders' logs/access.log.1 logs/access.log | grep 'status=500' > reports/orders-500.txt
#   files are read in the order listed (yesterday first); -h stops "logs/access.log.1:" prefixes
```
Also fine: `grep 'service=orders.*status=500' ...` (`.*` = "anything in between", works because
service= always comes before status= in these lines). `mkdir -p logs/archive reports` makes both folders at once.

Expected `reports/orders-500.txt`:
```
2026-09-27T10:02:17 service=orders method=POST status=500 3021ms
2026-09-28T09:03:29 service=orders method=POST status=500 2987ms
2026-09-28T09:06:48 service=orders method=GET status=500 3104ms
```

## Common wrong attempts (all of these lose the marks)
- Copying the paper's hint literally: `grep service=orders logs/access.log.1 | grep status=500 logs/access.log > reports/orders-500.txt`
  -> the second grep has a file, so it **ignores the pipe** and just prints today's status=500 lines. Yesterday is lost.
- No `mkdir reports` -> `bash: reports/orders-500.txt: No such file or directory`. The redirect fails before grep even runs.
- Using `>` for both greps -> the second one wipes the first; only today's 2 lines remain.
- Today first, then yesterday -> right lines, wrong order -> content check fails.
- `grep status=500 logs/access.log.1 logs/access.log` without `-h` -> lines start with `logs/access.log.1:`; and it also
  catches the `service=users` 500.
- `grep 500 ...` -> also matches any time like `500ms`. Be exact: `status=500`.
- Doing `mv` **first**, then `grep ... logs/access.log.1` -> `No such file or directory` (it now lives in `logs/archive/`).
  Either grep first (simplest) or use the new path.
- `mv logs/access.log.1 logs/archive` when `logs/archive` doesn't exist -> renames the log to a **file** named `archive`.
  With a trailing slash (`logs/archive/`) you'd get an error instead, which is safer.
- `cp` instead of `mv` -> `logs/access.log.1` is still there -> check fails ("Move (don't copy)").
