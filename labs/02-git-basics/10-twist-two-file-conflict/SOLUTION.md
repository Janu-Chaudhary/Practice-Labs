# Solution 10

```bash
git merge feature
#   CONFLICT (content): Merge conflict in config.py
#   CONFLICT (content): Merge conflict in greet.py
git status
#   Changes to be committed:   new file: docs/USAGE.md     <- no conflict, already staged
#   Unmerged paths:            both modified: config.py, greet.py
git checkout --theirs config.py   # take feature's whole version of this file
#   (--ours = the branch you are on, main; --theirs = the branch being merged in)
code greet.py                     # combine by hand, delete markers:
#       return f"Hi, {name}! Good to see you."
#   no-editor equivalent:
#   printf 'def greet(name):\n    return f"Hi, {name}! Good to see you."\n' > greet.py
git add config.py greet.py        # mark both resolved
git status                        # "All conflicts fixed but you are still merging."
git commit --no-edit
git log --oneline --graph --all --decorate
```

## Common wrong attempts
- Resolving only greet.py then committing: "error: Committing is not possible because you have unmerged
  files." `git status` lists what is still unmerged.
- `git add .` while markers are still in config.py: git happily marks it resolved with markers inside.
  Always `grep -n '<<<<<<<' *.py` (or `git diff --check`) before `git add`.
- Deleting docs/USAGE.md because "it wasn't on main": the merge should bring it in.
