# Solution 01

```bash
git remote add origin remote.git     # "origin" is just a nickname for this URL/path
git remote -v                        # shows origin remote.git (fetch) and (push)
git push -u origin main              # send main; -u remembers origin/main as main's upstream
echo "# Docs" > docs.md
git add docs.md
git commit -m "Add docs"
git push                             # works with no arguments because of -u
```

Why: `git push origin main` = "to the remote called origin, send my branch main". `-u`
(`--set-upstream`) writes `branch.main.remote=origin` into `.git/config`, so later `git push`,
`git pull` and the "ahead/behind" lines in `git status` know which remote branch to compare with.

Common wrong attempts
- `git push` before step 2 -> `fatal: No configured push destination` (no remote yet) or
  `fatal: The current branch main has no upstream branch` (remote exists, no -u yet).
- `git remote add origin` twice -> `error: remote origin already exists`. Fix a wrong URL with
  `git remote set-url origin remote.git`, or `git remote remove origin` and add again.
- Forgetting `git add docs.md` -> commit says "nothing added to commit", push sends nothing new.
