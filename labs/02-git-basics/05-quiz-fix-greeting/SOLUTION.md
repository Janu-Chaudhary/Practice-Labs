# Solution 05

```bash
git switch -c fix-greeting            # create + switch (or: git checkout -b fix-greeting)
```

Editor: open `greet.py` in the Files panel, change line 2, save with Ctrl+S. The file must be exactly:
```python
def greet(name):
    return f"Hello, {name}!"
```
Why after the switch: the edit is committed on the branch you are on, and that must be fix-greeting.

```bash
git diff                              # confirm only the return line changed
git add greet.py
git commit -m "Use f-string in greeting"
git log --oneline --graph --all --decorate   # (HEAD -> fix-greeting) on top of main
```

## Common wrong attempts
- Editing and committing BEFORE creating the branch: the commit is on main. If that happened:
  `git switch -c fix-greeting` (carries the commit) then `git branch -f main HEAD~1`.
- Forgetting to save the file in the editor (it still shows `● unsaved`): `git add` stages nothing,
  `git commit` says "nothing to commit". Always `git diff` / `git status` before committing.
- Typos: `"Hello, {name}!"` without the `f`, missing comma, 2-space indent. Content is checked exactly.
- Made an extra commit (e.g. a fix of a typo)? `git reset --soft HEAD~1` undoes the last commit and
  keeps its changes staged, then commit once.
