# Solution - 03 redirects and pipes

Step 1 is done in the editor: in the Files panel click **+ New file**, type `hello.txt`, type these two
lines, then save with Ctrl+S. Why the editor: this is text you type yourself, not the output of a command.
```
first line
second line
```

Then in the terminal:
```bash
cat hello.txt                          # check: the two lines are there (if not, you forgot to save)
head -n 3 visitors.txt > top3.txt      # head -n N = first N lines (tail -n N = last N)
wc -l < visitors.txt > line-count.txt  # < feeds the file as input, so wc doesn't know (or print) its name
sort visitors.txt | uniq > unique.txt  # sort puts duplicates next to each other, then uniq drops the repeats
cat hello.txt top3.txt line-count.txt unique.txt
```

`sort -u visitors.txt > unique.txt` (sort + unique in one) is also correct.
`cat visitors.txt | wc -l > line-count.txt` is also correct.

## Common wrong attempts
- Forgetting Ctrl+S in the editor -> `hello.txt` is empty on disk (`cat hello.txt` shows nothing). The editor shows `● unsaved` until you save.
- `uniq visitors.txt > unique.txt` (no sort) -> duplicates stay, because the two `maya` lines are not next to each other.
- `wc -l visitors.txt > line-count.txt` -> file holds `8 visitors.txt`, not just the number.
- `sort visitors.txt > visitors.txt` -> visitors.txt becomes **empty**: the shell truncates the `>` target before sort reads it.
