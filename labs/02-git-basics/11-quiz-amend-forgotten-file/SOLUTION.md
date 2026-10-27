# Solution 11

```bash
git status                          # todo.txt staged, settings.json untracked
git restore --staged todo.txt       # unstage: staging goes back to HEAD's todo.txt, disk keeps the edit
git add settings.json               # stage the forgotten file
git status                          # staged: new file settings.json; not staged: modified todo.txt
git commit --amend -m "Add settings loader"   # replace the last commit (loader.py + settings.json)
git log --oneline                   # still 2 commits, new hash on the top one
git show --stat HEAD                # loader.py and settings.json
git status                          # only: modified: todo.txt (not staged)
```

Why each step:
- `git restore --staged todo.txt` moves todo.txt from "to be committed" back to "not staged". It only
  touches the staging area; your file on disk is untouched. (Old-style equivalent: `git reset todo.txt`.)
- `git add settings.json`: `--amend` builds the new commit from the staging area, like any commit.
- `git commit --amend -m ...` throws away the old last commit and makes a new one with the same parent.
  The hash changes (new content + new message = new object). That's why you never amend a pushed commit.

## Common wrong attempts
- Amending first, then unstaging: the private todo.txt line is already inside the amended commit.
  Unstaging afterwards is too late (recover: `git reset --soft HEAD~1`, unstage, commit again).
- `git restore todo.txt` (no `--staged`): copies the STAGED version (with the private line) over the
  file on disk and leaves it staged. Wrong way round.
- `git commit -m "Add settings loader"` (no `--amend`): a third commit, and the typo commit stays.
  Fails "2 commits".
- `git commit --amend` without `-m`: opens vim. Fix the message on the first line, then `Esc :wq Enter`.
- `git commit -a --amend ...`: `-a` stages every tracked modified file, which includes todo.txt.
