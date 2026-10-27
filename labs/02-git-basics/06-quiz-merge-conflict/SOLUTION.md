# Solution 06

Predict first: both branches have a commit after the common ancestor, so this cannot fast-forward.
Both changed the SAME line, so it will conflict.

```bash
git merge feature
#   CONFLICT (content): Merge conflict in greet.py
#   Automatic merge failed; fix conflicts and then commit the result.
git status                  # "You have unmerged paths." / both modified: greet.py
```

Editor: open `greet.py` in the Files panel. It now looks like this:
```
def greet(name):
<<<<<<< HEAD
    return f"Hello, {name}! Welcome back."
=======
    return f"Hi there, {name}."
>>>>>>> feature
```
Delete ALL three marker lines and both old versions, and write the wanted line. Save with Ctrl+S.
The file must end up exactly:
```python
def greet(name):
    return f"Hi there, {name}! Welcome back."
```

Back in the terminal:
```bash
grep -n '<<<<<<<\|=======\|>>>>>>>' greet.py   # prints nothing = no markers left
git add greet.py            # "add" = mark as resolved
git commit --no-edit        # finish the merge with git's message "Merge branch 'feature'"
git log --oneline --graph --all --decorate
git rev-list --count main   # 4
```

## Common wrong attempts
- `git commit` without -m or --no-edit and getting stuck in vim: press Esc, type `:wq`, Enter.
- `git commit -m ...` before `git add`: "error: Committing is not possible because you have unmerged files."
- Leaving a marker line (`=======`) in the file: content check fails. Git does NOT stop you committing markers.
- Panicked? `git merge --abort` puts main back exactly as before the merge; start again.
- Made an extra commit after the merge (main now has 5)? `git reset --soft HEAD~1` removes only that last
  commit and keeps its changes staged. If unsure, `./setup.sh` and redo.
