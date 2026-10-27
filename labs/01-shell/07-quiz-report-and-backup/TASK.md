# 07 - Morning report and backup (Quiz-style, 6 marks)

## Situation
The current folder has:
- `logs/app.log` - today's application log. Each line: timestamp, `level=…` (INFO, WARN, ERROR, DEBUG), `service=…`, `msg="…"`.
- `notes.txt` - the on-call notes. It already has two lines that must be kept.

There is no `reports` folder and no `backup` folder yet.

## Task
1. Create `reports/problems.txt` with every `WARN` **or** `ERROR` line from `logs/app.log`, in log order.
2. Create `reports/error-count.txt` holding only the **number** of `level=ERROR` lines.
3. Copy `logs/app.log` into a new folder `backup`, named `app-2026-10-25.log`.
4. Add this line to the **end** of `notes.txt` (keep the existing lines):
   ```
   2026-10-25 checked by me
   ```

## Stop
- Don't change or move `logs/app.log`.
- Don't remove anything from `notes.txt`.

## Hints
- Read every line: one DEBUG message contains the word ERROR. Your patterns should match the *level*, not any word.
- `cp SOURCE DEST` can rename while copying.

## What will be checked
- `reports/problems.txt` has exactly the 4 expected lines
- `reports/error-count.txt` holds just `2`
- `backup/app-2026-10-25.log` is an identical copy of `logs/app.log`
- `notes.txt` has 3 lines: the 2 old ones, then the new one
- `logs/app.log` is unchanged and still in `logs/`
