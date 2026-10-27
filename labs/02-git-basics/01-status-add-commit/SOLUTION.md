# Solution 01

```bash
git status                       # see: server.py modified (working dir), routes/ + debug.log untracked
git diff                         # shows the unstaged edit to server.py (working dir vs staging)
git add app/server.py            # stage ONLY that file
git status                       # server.py now under "Changes to be committed"
git commit -m "Handle empty payload"   # commit = what is staged, nothing else
```

Now the editor: Files panel -> **+ New file** -> `.gitignore`, type the line below, save with Ctrl+S.
Why: `.gitignore` tells `git add` to skip every untracked file that matches `*.log`.
```
*.log
```

Back in the terminal:
```bash
git status                       # debug.log is gone from "Untracked files"; .gitignore is new
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
- Naming the file `gitignore` or `.gitignore.txt`: git only reads a file called exactly `.gitignore`,
  so `git status` still lists debug.log. Rename it with `mv` (it is not committed yet).
- Not saving the new file (no Ctrl+S): `.gitignore` is empty, so `git add .` still stages debug.log.
