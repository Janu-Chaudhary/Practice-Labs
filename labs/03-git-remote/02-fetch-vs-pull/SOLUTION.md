# Solution 02

```bash
git fetch                          # download new commits; moves origin/main only
git status                         # "Your branch is behind 'origin/main' by 2 commits, and can be fast-forwarded."
git log --oneline main..origin/main  # commits on origin/main that main doesn't have
git pull                           # = fetch + merge origin/main into main -> Fast-forward
ls                                 # config.py and README.md appear now
```

Why: fetch updates the **local repository** only (the `origin/main` pointer + objects). Your
**working directory** and `main` stay as they were. `pull` = `fetch` then `merge`, and the merge is
what moves `main` and rewrites files on disk. Because `main` had nothing new, the merge is a
fast-forward: git just slides the `main` pointer forward, no merge commit.

`git merge origin/main` after the fetch gives exactly the same result as `git pull`.

Common wrong attempts
- Expecting `ls` to show the new files right after `git fetch`. It won't; that's the point of fetch.
- `git log main..origin/main` with no fetch first -> empty: your origin/main is still old.
