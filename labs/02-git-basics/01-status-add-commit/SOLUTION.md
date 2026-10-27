# Solution 01

```bash
git status                       # see: server.py modified (working dir), routes/ + debug.log untracked
git diff                         # shows the unstaged edit to server.py (working dir vs staging)
git add app/server.py            # stage ONLY that file
git status                       # server.py now under "Changes to be committed"
git commit -m "Handle empty payload"   # commit = what is staged, nothing else
echo '*.log' > .gitignore        # tell git add to skip every .log file
git status                       # debug.log is gone from "Untracked files"
git add .                        # now safe: stages .gitignore and routes/webhooks.py
git commit -m "Add webhook route"
git status                       # nothing to commit, working tree clean
```

## Common wrong attempts
- `git commit -am "..."` as step 2: `-a` stages modified *tracked* files only. It works for server.py,
  but people then expect it to include routes/webhooks.py too. It never adds untracked files.
- `git add .` before writing .gitignore: debug.log gets staged. Fix with `git restore --staged debug.log`
  (or `git rm --cached debug.log` if already committed).
- One commit with everything: fails "HEAD~1 changed only app/server.py". One change per commit.
- `echo *.log > .gitignore` without quotes: the shell expands `*.log` to `debug.log`. It happens to
  work here, but quote patterns: `echo '*.log'`.
