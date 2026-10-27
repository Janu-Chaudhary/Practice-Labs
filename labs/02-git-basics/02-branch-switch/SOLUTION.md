# Solution 02

```bash
git switch -c docs                    # -c = create then switch (same as: git checkout -b docs)
```

Editor: open `README.md` in the Files panel, go to the end, press Enter, type the new line, save
with Ctrl+S. The new last line is:
```
## Install
```
Why now: you are on `docs`, so the commit that follows lands on docs, not main.

```bash
git diff                              # check: one added line, + ## Install
git commit -am "Add install section"  # -a ok here: README.md is already tracked
git switch main                       # README.md on disk goes back to main's version
git branch hotfix                     # creates the pointer only, you stay on main
git branch                            # list: * marks the current branch
git log --oneline --graph --all --decorate
```

## Common wrong attempts
- `git branch docs` then editing: you are still on main, so the commit lands on main (check fails
  "main still has 2 commits"). `git branch X` creates, it does not switch.
- `git switch docs` before it exists: `fatal: invalid reference: docs`. Use `-c`.
- `git switch -c hotfix`: works but leaves you on hotfix. Then `git switch main`.
- Forgetting to save in the editor: `git commit -am` says "nothing to commit". Save, then commit.
- Editing README.md before `git switch -c docs`: the edit is still uncommitted, so it simply comes
  with you to docs. That's fine, as long as you commit only after switching.
