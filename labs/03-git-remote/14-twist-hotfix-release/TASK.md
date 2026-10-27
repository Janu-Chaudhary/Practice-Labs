# 14 · Twist · Hotfix: push main, and put ONLY the fix on the release branch

```
$ git log --graph --oneline --all --decorate
* 41cf8ae (HEAD -> main) Add dark mode
* 434765e Fix price rounding
* c610ed6 (origin/main) Add price
* f8cdbc6 Add app

$ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)
```
(Your hashes will be different.)

**Context:** you made two commits on main, not pushed yet: "Fix price rounding" (a bug fix in
price.py: `round(x)` → `round(x, 2)`) and "Add dark mode" (a new feature). `git status` looks
happy, but it only knows the origin/main from your last fetch. Since then a teammate:
- pushed "Add wishlist" to main, and
- created a branch `release-1.0` on origin (from "Add price", plus a commit "Set version 1.0").
  That's what customers run. It must get bug fixes only, **never features**.

Team rule: main stays **linear** (no merge commits).

**Task:**
1. `git push` and read the rejection. Then `git fetch` and look at both sides:
   `git log --oneline main..origin/main` (what origin has that you don't) and
   `git log --oneline origin/main..main` (what you have that origin doesn't).
2. Put your two commits on top of the teammate's main without a merge commit, then push main.
3. Get a local `release-1.0` that tracks `origin/release-1.0`.
4. Copy **only** "Fix price rounding" onto release-1.0 and push release-1.0.
5. End on main.

**Stop:** no force push, no merge commits, don't put "Add dark mode" or "Add wishlist" on the
release branch, make no other commits.

**Hints:**
- Before step 3, `git branch -r` must list `origin/release-1.0`. If it doesn't, what haven't you
  done yet?
- Find the fix's hash with `git log --oneline | grep "price rounding"`. Either hash (before or
  after your rebase) works: the change is the same.
- Optional: `git cherry-pick -x <hash>` adds "(cherry picked from commit ...)" to the message, a
  common habit for hotfixes.

**What will be checked**
- on main, clean, nothing in progress
- main on origin: teammate's commit untouched, linear, 5 commits, yours on top in order, == local
- release-1.0 on origin: old tip + exactly one commit "Fix price rounding"
- release-1.0 has `round(x, 2)` but no wishlist.py and no theme.py
- local release-1.0 tracks origin/release-1.0 and equals it
