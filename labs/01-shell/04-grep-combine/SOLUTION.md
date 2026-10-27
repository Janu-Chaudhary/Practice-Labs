# Solution - 04 combining greps

```bash
cat logs/a.log logs/b.log
grep 'service=orders' logs/a.log | grep 'method=POST' > orders-post.txt
#   first grep reads the FILE; second grep has NO file, so it reads the pipe = AND
grep -h 'status=500' logs/a.log logs/b.log > all-500.txt
#   files are read in the order you list them; -h hides the "logs/a.log:" prefix
grep -E 'method=(GET|DELETE)' logs/a.log > get-or-delete.txt
#   -E = extended regex, | inside the quotes means OR. Also fine: grep -E 'method=GET|method=DELETE'
grep -w 'user=7' logs/a.log > user7.txt
#   -w = whole word: "user=7" must not be followed by a letter/digit, so user=71 is skipped
```

## Common wrong attempts
- `grep 'service=orders' logs/a.log | grep 'method=POST' logs/a.log` -> gives **every** POST line (users too).
  When the second grep is given a file name, it reads that file and **ignores the pipe**. In an AND-chain,
  only the first grep gets the file.
- `grep 'status=500' logs/a.log logs/b.log > all-500.txt` (no `-h`) -> lines look like `logs/a.log:2026-...`.
  With one file grep prints no names; with two or more it does.
- `grep -E method=GET|DELETE logs/a.log` (no quotes) -> the shell sees `|` as a pipe and tries to run a
  command called `DELETE` -> `DELETE: command not found`, and the grep
  (which now has no file) sits waiting for keyboard input. Press Ctrl+C to get your prompt back.
- `grep 'method=GET|method=DELETE' logs/a.log` (no `-E`) -> nothing found: in basic grep `|` is a normal character.
- `grep 'user=7' logs/a.log` -> also matches `user=71`. Use `-w` (or `'user=7 '` with a trailing space).
