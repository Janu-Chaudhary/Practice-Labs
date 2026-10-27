# 13 · Twist · Tidy up remote branches (prune, track, push -u, delete on origin)

```
$ git log --graph --oneline --all --decorate
* 6a05fc4 (HEAD -> report) Add sales report
| * b0d0606 (origin/experiment) Try a cache
|/
| * 99a6d9e (origin/old-ui) Old UI
|/
* 7c21a81 (origin/main, main) Add app

$ git branch -vv
  main   7c21a81 [origin/main] Add app
* report 6a05fc4 Add sales report
```
(Your hashes will be different.)

**Context:** origin is `remote.git`. Your `origin/...` names are only copies from your last fetch.
Since then a teammate **deleted** `old-ui` on origin, pushed a **new** branch `search`, and pushed
one more commit to `main`. Your own branch `report` has never been pushed (no `[origin/...]` next
to it in `git branch -vv`). The branch `experiment` on origin is dead and should go.

**Task:**
1. Update your view of origin so that `origin/old-ui` **disappears** from `git branch -r` and
   `origin/search` appears. (A plain `git fetch` adds new names but never removes old ones.)
2. Create a local branch `search` that **tracks** `origin/search` (so plain `git pull` works on it).
3. On `main`: read `git status` (ahead? behind? by how many?) and bring local `main` up to date
   with origin's main. It must be a fast-forward, no merge commit.
4. Push `report` to origin **and** set its upstream, so `git branch -vv` shows `[origin/report]`.
5. Delete the branch `experiment` **on origin**.
6. End on `report`.

**Stop:** don't push to main, don't change or delete `search` on origin, make no commits.

**Hints:**
- `git switch <name>`: if no local branch has that name but `origin/<name>` exists, git creates
  the local branch from it and sets up tracking for you.
- Deleting a branch locally (`git branch -d`) never touches origin. Deleting on origin is a
  **push** (you're changing the remote). Look up `git push origin --delete`.
- Check yourself with `git branch -vv` (local branches + their upstream + ahead/behind) and
  `git branch -r` (your copies of origin's branches). `git ls-remote origin` asks origin directly.

**What will be checked**
- on report, clean; `origin/old-ui` and `origin/experiment` gone from your repo
- `experiment` gone from origin; origin has exactly main, report, search
- local `search` = teammate's commit and tracks origin/search
- `report` on origin, unchanged, upstream origin/report
- local main = origin's main (the teammate's "Add README")
