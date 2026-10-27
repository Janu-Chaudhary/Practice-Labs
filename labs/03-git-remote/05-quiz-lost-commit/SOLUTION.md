# Solution 05

```bash
git reflog | grep "rate limit"       # bc59506 HEAD@{1}: commit: Add rate limit config
git branch rate-limit bc59506        # YOUR hash. Pointer only; you stay on main
git branch                           # * main   rate-limit
git merge --no-edit rate-limit       # Merge made by the 'ort' strategy. limits.py appears
git log --oneline --graph --all      # merge commit with two parents
git push origin main                 # or just `git push` (main already tracks origin/main)
git status                           # Your branch is up to date with 'origin/main'.
```

Why 4 commits: Add request handler, Add README, Add rate limit config, and the merge commit.
`git rev-list --count main` counts every commit reachable from main by following parent links.

Why it's needed: when HEAD is detached, a new commit is pointed to only by HEAD itself. When you
switch away, nothing points at it, so `git log` (and even `git log --all`) can't reach it. The
commit still exists; the reflog still lists it (for ~90 days by default). Giving it a branch makes it
reachable again.

Other ways for step 2: `git switch -c rate-limit bc59506` (then `git switch main` before merging),
or `git branch rate-limit HEAD@{1}`.

Common wrong attempts
- `git merge bc59506` without creating the branch -> main is fine, but check "rate-limit is the
  commit..." fails.
- Being on rate-limit when you merge (`git merge main`) -> you merged the wrong direction; main
  doesn't move.
- `git push` while on rate-limit / `git push origin rate-limit` / `git push --all` -> pushes rate-limit.
- `git cherry-pick bc59506` -> copies the change as a NEW commit (new hash): rate-limit isn't merged
  and main has 3 commits.
