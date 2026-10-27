# Solution - 07 report and backup

```bash
cat logs/app.log notes.txt
mkdir reports backup
#   neither > nor cp creates folders
grep -E 'level=(WARN|ERROR)' logs/app.log > reports/problems.txt
#   -E so that | means OR; matching "level=" skips the DEBUG line whose message says ERROR
grep -c 'level=ERROR' logs/app.log > reports/error-count.txt
#   -c prints only the count (one file -> no file name)
cp logs/app.log backup/app-2026-10-25.log
#   copy + new name in one step; original untouched
echo "2026-10-25 checked by me" >> notes.txt
#   >> appends; > would wipe the 2 existing lines
cat reports/problems.txt reports/error-count.txt notes.txt
```

## Common wrong attempts
- `grep -E 'WARN|ERROR' logs/app.log` -> 5 lines; the DEBUG line with `msg="ERROR count reset"` sneaks in.
- `grep 'WARN|ERROR'` without `-E` -> nothing matches (in basic grep `|` is a literal character).
- `grep -E WARN|ERROR logs/app.log` (no quotes) -> the shell makes a pipe: `ERROR: command not found`.
- `grep -c ERROR logs/app.log` -> `3` (counts the DEBUG line too).
- `echo "2026-10-25 checked by me" > notes.txt` -> notes.txt now has 1 line. Old notes lost.
- `cp logs/app.log backup/app-2026-10-25.log` before `mkdir backup` -> `cp: cannot create regular file 'backup/app-2026-10-25.log': No such file or directory`.
- `mv` instead of `cp` -> `logs/app.log` is gone.
