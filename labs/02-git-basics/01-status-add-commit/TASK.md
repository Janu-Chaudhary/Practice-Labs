# 01 - status, add, commit (Drill)

## Situation
```
$ git log --oneline
xxxxxxx (HEAD -> main) Add server

$ git status
On branch main
Changes not staged for commit:
        modified:   app/server.py
Untracked files:
        debug.log
        routes/
```
You changed `app/server.py` (handle an empty payload), started a new file `routes/webhooks.py`,
and the server wrote a `debug.log` that must never be committed.

## Task
1. Run `git status` and `git diff` first and read them (which location is each file in?).
2. Commit **only** `app/server.py` with message `Handle empty payload`.
3. Create a `.gitignore` containing the line `*.log`: in the Files panel click **+ New file**, type
   `.gitignore`, type this one line, save with Ctrl+S:
   ```
   *.log
   ```
4. Commit `routes/webhooks.py` and `.gitignore` together with message `Add webhook route`.

## Stop
Exactly two new commits. `debug.log` must stay on disk but never be committed. Do not use `git add .`
before the `.gitignore` exists (it would stage debug.log).

## What will be checked
- main has 3 commits
- HEAD~1 is "Handle empty payload" and changed only app/server.py
- HEAD is "Add webhook route" and adds only .gitignore + routes/webhooks.py
- .gitignore contains `*.log`; debug.log not committed but still exists
- working tree clean
