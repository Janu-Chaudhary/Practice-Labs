# Solution 04

```bash
git reset --soft HEAD~1         # move main back one commit; staging + files untouched
git status                      # both files under "Changes to be committed"
git restore --staged debug.log  # take debug.log out of staging; file stays on disk (untracked)
git commit -m "Add discount"
git show --stat HEAD            # only discount.py
```

Why: `HEAD~1` = "the parent of the current commit". `reset` moves the branch pointer back to it.
- `--soft`: only the pointer moves. Staging area and working directory keep everything -> you can
  recommit right away.
- `--mixed` (the default): pointer moves AND staging is reset; changes stay on disk, unstaged.
- `--hard`: pointer, staging AND working directory reset -> your changes are gone. Never here.

Another way: `git rm --cached debug.log` then `git commit --amend -m "Add discount"`.
(`--amend` replaces the last commit with a new one; same result, new hash.)

Common wrong attempts
- `git reset --hard HEAD~1` -> discount.py and debug.log vanish from disk.
- `git rm debug.log` -> deletes the file from disk too.
- `git commit` without removing debug.log first -> 3 commits, debug.log still in history.
- Only do this on commits that are NOT pushed. For pushed commits use `git revert` (lab 08).
