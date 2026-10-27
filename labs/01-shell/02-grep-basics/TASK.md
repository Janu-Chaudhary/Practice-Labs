# 02 - grep basics (Drill)

## Situation
The current folder holds `app.log`. Each line is one log entry: timestamp, `level=...`, `service=...`, `msg=...`.
Look at it first: `cat app.log`.

Some error lines were written as `level=ERROR` and one as `level=error` (lower case).

## Task
Create these four files in the current folder (each is the output of one grep, saved with `>`):

1. `errors.txt` - every error line, whatever its case (`ERROR` or `error`), in the original order.
2. `warn-count.txt` - only the **number** of `WARN` lines (just the number, nothing else).
3. `no-health.txt` - every line **except** the `service=health` lines.
4. `db-numbered.txt` - the `service=db` lines, each starting with its line number in `app.log` (like `3:2026-...`).

## Stop
- Don't change `app.log`.

## Hints
- `grep --help | less` (press `q` to quit). Look for: ignore case, count, invert, line number.
- Check each file with `cat` before you move on.

## What will be checked
- each of the four files has exactly the expected content
- `app.log` is unchanged
