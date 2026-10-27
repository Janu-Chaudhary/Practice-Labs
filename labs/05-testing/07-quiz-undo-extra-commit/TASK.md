# 05-testing / 07 - Undo an accidental extra commit  (Quiz-style)

## Situation
You did the failing-test-then-fix workflow correctly... and then typed `git add . && git commit -m wip`
by habit. Now main has **4** commits instead of 3:

```
xxxxxxx (HEAD -> main) wip                                        <- accidental
xxxxxxx Fix letter grade so 80 is an A
xxxxxxx Add failing test for score of exactly 80
xxxxxxx Add letter grades
```
The `wip` commit added your private `notes.txt` and a `print("DEBUG ...")` line in `grade.py`.
Nothing was pushed.

## Task
1. Undo the `wip` commit so main ends at "Fix letter grade so 80 is an A" again.
2. Keep `notes.txt` on disk (you still want it) but it must **not** be tracked or staged.
3. Throw away the debug print in `grade.py`.

## Stop
- Do not create new commits (no `git revert`: that adds a 5th commit instead of removing one).
- Do not rewrite the test or fix commits (no `--amend`, no new commit IDs for them).

## What will be checked
- 3 commits; HEAD is exactly the original fix commit
- notes.txt exists, is untracked, nothing staged
- grade.py equals the fix version (no DEBUG line); pytest passes
