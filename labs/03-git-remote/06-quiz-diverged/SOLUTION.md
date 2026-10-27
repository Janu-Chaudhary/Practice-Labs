# Solution 06

Option A (pull):
```bash
git pull --no-rebase --no-edit     # fetch + merge origin/main into main -> merge commit
git push                           # now main contains origin/main, so it's a fast-forward for the remote
```

Option B (fetch + merge), same result:
```bash
git fetch origin
git merge --no-edit origin/main
git push origin main
```

Why the push was rejected: a push may only move the remote's main **forward** (fast-forward). The
remote's main is "Add README"; your main doesn't contain it, so accepting your push would drop it.
After the merge, your main contains both commits (the merge commit has two parents), so the remote
can just move forward to it.

Common wrong attempts
- `git push --force` -> remote main becomes yours; teammate's "Add README" is erased from origin.
- `git reset --hard origin/main` then `git push` -> your "Log each request" is thrown away
  (pointer moved back, files overwritten). Push then says "Everything up-to-date".
- Plain `git pull` -> `fatal: Need to specify how to reconcile divergent branches.` (nothing happened;
  rerun with `--no-rebase`, or set once: `git config pull.rebase false`).
- `git pull --rebase` -> valid in real life (3 commits, linear), but this task asked for a merge
  (4 commits). Lab 09 is the rebase version.
