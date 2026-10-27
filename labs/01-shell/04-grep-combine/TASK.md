# 04 - Combining greps (Drill)

## Situation
The current folder has a folder `logs` with two access logs from two servers: `logs/a.log` and `logs/b.log`.
Each line: timestamp, `service=`, `method=`, `status=`, `user=` and the time taken. Look at them first.

## Task
Create these files in the current folder:

1. `orders-post.txt` - lines from `logs/a.log` that are **both** `service=orders` **and** `method=POST`.
2. `all-500.txt` - every `status=500` line from **both** logs: `a.log`'s lines first, then `b.log`'s.
   The lines must look exactly like in the logs (no file names in front).
3. `get-or-delete.txt` - lines from `logs/a.log` whose method is `GET` **or** `DELETE`, in log order.
4. `user7.txt` - lines from `logs/a.log` for user 7 only (`user=7`, **not** `user=71`).

## Stop
- Don't change either log.

## Hints
- One grep can't say "A and B" easily, but two greps joined by `|` can.
- When grep reads more than one file it puts `filename:` in front of each line. Find the option that hides it (`grep --help`).
- `grep -E 'x|y'` means x OR y. Quote the pattern, or the shell treats `|` as a pipe.
- Look for the grep option that only matches whole words.

## What will be checked
- each of the four files has exactly the expected lines, in order
- both logs are unchanged
