# Solution - 02 grep basics

```bash
cat app.log                                   # always look at the data first
grep -i 'level=error' app.log > errors.txt    # -i = ignore case, so ERROR and error both match
grep -c 'level=WARN' app.log > warn-count.txt # -c = print the COUNT of matching lines instead of the lines
grep -v 'service=health' app.log > no-health.txt  # -v = invert: keep lines that do NOT match
grep -n 'service=db' app.log > db-numbered.txt    # -n = put "LINENUMBER:" in front of each match
cat errors.txt warn-count.txt no-health.txt db-numbered.txt   # check your work
```

Why the pattern is `level=error` and not just `error`: the more exact the pattern, the less chance it matches
something you didn't mean (for example a message that contains the word "error").

## Common wrong attempts
- `grep ERROR app.log > errors.txt` -> only 2 lines. grep is case-sensitive by default; `level=error` is missed.
- `grep WARN app.log | wc -l > warn-count.txt` also gives `2` and is fine. `wc -l app.log` would print `8 app.log` (the name is added), which is not "just the number".
- `grep -v health app.log > app.log` -> **empties app.log!** The shell opens (and truncates) the `>` file *before* grep runs, so grep reads an empty file (GNU grep even warns `input file is also the output`). Never redirect into the file you are reading.
- `grep -n service=db app.log` without `> db-numbered.txt` just prints to the screen; nothing is saved.
