# Solution - 08 failures per service

Build the pipe one stage at a time and look at the output after each stage:

```bash
grep 'status=5' logs/access.log
#   every 5xx line (500, 502, 503, 504). Not "500": that would miss 502/503/504 and catch "500ms"
grep 'status=5' logs/access.log | cut -d' ' -f2
#   cut: split on spaces (-d' '), keep field 2 -> service=orders, service=users, ...
grep 'status=5' logs/access.log | cut -d' ' -f2 | sort
#   sort puts identical names next to each other (uniq needs that)
mkdir reports
grep 'status=5' logs/access.log | cut -d' ' -f2 | sort | uniq -c > reports/failures.txt
#   uniq -c: collapse repeats and prefix the count
cat reports/failures.txt
#         3 service=orders
#         2 service=payments
#         1 service=users
sort -rn reports/failures.txt | head -n 1 > reports/top.txt
#   -n numeric, -r biggest first, head -n 1 keeps the top line
```

Alternatives that also pass: `grep -o 'service=[a-z]*'` instead of `cut` (`-o` prints only the matched part);
`grep -E 'status=5[0-9]{2}'` as the filter (exact "5 then two digits").

## Common wrong attempts
- `grep 500 logs/access.log` -> misses 502/503/504, and catches `service=search ... 500ms`.
- `... | uniq -c` without `sort` first -> the same service can appear on several lines (only neighbours are merged).
- `sort -r reports/failures.txt` without `-n` -> text sort; works here by luck but fails with counts like 10 vs 9.
- `cut -f2` without `-d' '` -> cut splits on TAB by default, so it prints the whole line.
- `sort -rn reports/failures.txt > reports/failures.txt` -> empties the file (shell truncates the target first).
