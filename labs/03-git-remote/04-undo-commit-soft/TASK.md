# 04 · Drill · Undo the last commit, keep the work (`reset --soft`)

```
$ git log --oneline --stat
376bab7 (HEAD -> main) Add discount
 debug.log   | 2 ++
 discount.py | 1 +
ed6baa8 Add cart
 cart.py | 1 +
```

**Context:** your last commit "Add discount" accidentally included `debug.log`, a log file that
should never be committed. Nothing is pushed.

**Task:** make "Add discount" contain only `discount.py`:
1. Undo the last commit but keep its changes staged (`git reset --soft HEAD~1`).
2. Unstage `debug.log` (keep the file on disk).
3. Commit again with message `Add discount`.

**Stop:** main must have exactly 2 commits. Don't delete debug.log.

**What will be checked**
- main has 2 commits, last is "Add discount"
- discount.py is in the last commit, debug.log is not
- debug.log still exists in the folder; nothing left staged
