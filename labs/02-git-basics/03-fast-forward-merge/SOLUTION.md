# Solution 03

Prediction: **fast-forward**. main is a direct ancestor of feature (main has nothing new), so git
just slides the main pointer forward to feature's tip. No new commit, no editor, no conflict.

```bash
git log --oneline --graph --all --decorate   # main is BELOW feature on the same line
git merge feature                            # output says "Fast-forward"
git log --oneline --graph --all --decorate   # (HEAD -> main, feature) on the same commit
```

## Common wrong attempts
- Running `git merge main` while on main ("Already up to date."): merge pulls the NAMED branch into the
  CURRENT one. Be on main, name feature.
- Being on feature and running `git merge main`: also "Already up to date", main does not move.
- `git merge --no-ff feature`: forces a merge commit, so main would have 4 commits (check fails).
