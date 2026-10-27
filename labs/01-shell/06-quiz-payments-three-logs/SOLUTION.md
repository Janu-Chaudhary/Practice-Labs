# Solution - 06 payments across three logs

```bash
cat logs/app.log.2 logs/app.log.1 logs/app.log      # look first: spot the 503ms trap
mkdir -p reports logs/archive/2026-10
#   -p makes logs/archive AND logs/archive/2026-10 (and reports) in one go
grep -h 'service=payments' logs/app.log.2 logs/app.log.1 logs/app.log | grep 'status=503' > reports/payments-503.txt
#   files listed oldest -> newest; -h removes "logs/app.log.2:" prefixes; 2nd grep reads the pipe (AND)
cat reports/payments-503.txt                          # 4 lines, 10-22 first
mv logs/app.log.2 logs/app.log.1 logs/archive/2026-10/
#   several sources + a folder at the end = move them all in, names kept
ls -R logs
```

Step-by-step version (same result):
```bash
grep 'service=payments' logs/app.log.2 | grep 'status=503' >  reports/payments-503.txt
grep 'service=payments' logs/app.log.1 | grep 'status=503' >> reports/payments-503.txt
grep 'service=payments' logs/app.log   | grep 'status=503' >> reports/payments-503.txt
```

## Common wrong attempts
- `grep 503 ...` or `grep -h payments ... | grep 503` -> includes `... status=200 503ms`. Match `status=503`.
- `grep -h ... logs/app.log*` -> the shell sorts the glob A-Z: `app.log app.log.1 app.log.2` = **newest first**. Wrong order. Type the files in the order you need.
- `mkdir logs/archive/2026-10` without `-p` -> `No such file or directory` because `logs/archive` doesn't exist.
- Moving first, then grepping the old paths -> `grep: logs/app.log.2: No such file or directory`.
- `mv logs/app.log* logs/archive/2026-10/` -> also moves today's `app.log`. Stop rule broken.
