# Solution - 03 redirects and pipes

```bash
echo "first line" > hello.txt          # > creates the file (or wipes it) and writes one line
echo "second line" >> hello.txt        # >> appends: the first line survives
head -n 3 visitors.txt > top3.txt      # head -n N = first N lines (tail -n N = last N)
wc -l < visitors.txt > line-count.txt  # < feeds the file as input, so wc doesn't know (or print) its name
sort visitors.txt | uniq > unique.txt  # sort puts duplicates next to each other, then uniq drops the repeats
cat hello.txt top3.txt line-count.txt unique.txt
```

`sort -u visitors.txt > unique.txt` (sort + unique in one) is also correct.
`cat visitors.txt | wc -l > line-count.txt` is also correct.

## Common wrong attempts
- Using `>` for the second echo -> `hello.txt` holds only `second line`. `>` always starts the file from empty.
- `uniq visitors.txt > unique.txt` (no sort) -> duplicates stay, because the two `maya` lines are not next to each other.
- `wc -l visitors.txt > line-count.txt` -> file holds `8 visitors.txt`, not just the number.
- `sort visitors.txt > visitors.txt` -> visitors.txt becomes **empty**: the shell truncates the `>` target before sort reads it.
- `echo first line second line > hello.txt` -> one line `first line second line`. Each `echo` writes one line.
