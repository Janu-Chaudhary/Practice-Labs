# 02 · Drill · fetch, look, then pull

```
$ git log --graph --oneline --all --decorate
* 89e1b03 (HEAD -> main, origin/main) Add app

$ git status
On branch main
Your branch is up to date with 'origin/main'.
```

**Context:** `main` has one commit, already pushed to `origin` (the bare repo `remote.git`).
While you were away a teammate pushed two commits to origin's `main`. Your local repository
doesn't know yet, so `git status` still says "up to date" (it only compares with the copy of
origin/main you downloaded last time).

**Task:**
1. Run `git fetch`. Then run `git status` and `git log --oneline --all --graph`. Notice: the
   message changes to "behind by 2 commits", `origin/main` moved, but `ls` shows your files did
   NOT change.
2. See exactly what arrived: `git log --oneline main..origin/main`.
3. Bring the commits into `main` (either `git pull`, or `git merge origin/main`). It should
   say `Fast-forward`.

**Stop:** don't make any commits yourself.

**What will be checked**
- main has 3 commits, no merge commit
- main == origin/main == remote main
- config.py and README.md exist in your folder; working tree clean
