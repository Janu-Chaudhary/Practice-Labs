# Solution 02

```bash
git switch -c docs                    # -c = create then switch (same as: git checkout -b docs)
echo '## Install' >> README.md        # >> appends a line (or edit with: code README.md)
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
- `echo '## Install' > README.md` (one `>`) overwrites the whole file.
