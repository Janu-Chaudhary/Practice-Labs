# Solution 03

```bash
git reflog | grep "refund"          # e.g.  6c4f777 HEAD@{1}: commit: Add refund handler
git branch payments 6c4f777         # use YOUR hash; makes a pointer file, does not switch
git log --oneline payments          # Add refund handler / Add payment model / Add app
git branch                          # * main, payments  (still on main)
```

Why: `git reflog` is a diary of every place HEAD has been on this machine (commits, checkouts,
merges, resets). The commit you made while on payments is in it. `git branch <name> <hash>` writes
`.git/refs/heads/<name>` containing that hash: the branch is back, exactly as before.

Also possible: `git reflog` line `checkout: moving from payments to main` - the entry just below it
(HEAD@{1}) is where payments was when you left it. Or use `git branch payments HEAD@{1}`.

Common wrong attempts
- `git switch -c payments 6c4f777` -> also recreates it, but switches you to payments (stop rule
  says stay on main). Run `git switch main` after.
- `git branch payments` with no hash -> creates payments at the current commit (main), not the old tip.
- `git log` / `git log --all` doesn't show the lost commits: no branch points at them anymore.
