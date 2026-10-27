# Solution 08

```bash
git merge feature
#   error: Your local changes to the following files would be overwritten by merge:
#           notes.txt
#   Please commit your changes or stash them before you merge.
git stash                    # WIP saved in the "drawer"; working tree is clean now
git status                   # nothing to commit, working tree clean
git merge feature --no-edit  # 3-way merge -> merge commit, default message, no editor
git stash pop                # re-applies the WIP edit and deletes it from the stash
git status                   # modified: notes.txt (unstaged)  -> exactly what we had before
git stash list               # empty
```

Why a merge commit: main got "Add app" after feature branched off, so main is not an ancestor of
feature. Git must build a new commit with two parents (main's tip and feature's tip).

## Common wrong attempts
- `git commit -am "wip"` to get past the error: adds a 5th commit to main and commits the WIP (fails).
- `git merge feature` without `--no-edit` opens vim/nano for the message. Save and quit (vim `:wq`,
  nano Ctrl+O Enter Ctrl+X).
- `git stash apply` instead of `pop`: the edit comes back but the stash entry stays (check fails).
  Run `git stash drop`.
- `git restore notes.txt` to get past the error: throws your WIP away for good.
