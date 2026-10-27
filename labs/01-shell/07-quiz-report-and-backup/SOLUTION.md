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
```

Step 4 is done in the editor (it is text you type, not a command's output): in the Files panel open
`notes.txt`, put the cursor at the end of the last line, press Enter, type the new line, save with Ctrl+S.
`notes.txt` must end up as:
```
On-call notes
2026-10-24 checked by Sam
2026-10-25 checked by me
```

Then check everything in the terminal:
```bash
cat reports/problems.txt reports/error-count.txt notes.txt
```

## Common wrong attempts
- `grep -E 'WARN|ERROR' logs/app.log` -> 5 lines; the DEBUG line with `msg="ERROR count reset"` sneaks in.
- `grep 'WARN|ERROR'` without `-E` -> nothing matches (in basic grep `|` is a literal character).
- `grep -E WARN|ERROR logs/app.log` (no quotes) -> the shell makes a pipe: `ERROR: command not found`.
- `grep -c ERROR logs/app.log` -> `3` (counts the DEBUG line too).
- Typing the new line over an old one (or deleting the old lines) in the editor -> notes.txt no longer has the 2 old lines.
- Not saving (no Ctrl+S) -> `cat notes.txt` still shows only 2 lines.
- `cp logs/app.log backup/app-2026-10-25.log` before `mkdir backup` -> `cp: cannot create regular file 'backup/app-2026-10-25.log': No such file or directory`.
- `mv` instead of `cp` -> `logs/app.log` is gone.
