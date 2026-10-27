# Solution 13

```bash
git fetch --prune                  # download new stuff AND delete origin/* names that origin dropped
                                   #  - [deleted]  (none) -> origin/old-ui
                                   #  * [new branch] search -> origin/search
git branch -r                      # origin/experiment, origin/main, origin/search
git switch search                  # "branch 'search' set up to track 'origin/search'"
git switch main
git status                         # Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
git pull                           # Fast-forward (or: git merge --ff-only origin/main)
git switch report
git push -u origin report          # creates report on origin + remembers origin/report as upstream
git push origin --delete experiment   # - [deleted] experiment   (also removes your origin/experiment)
git branch -vv                     # main [origin/main], report [origin/report], search [origin/search]
git ls-remote --heads origin       # origin itself: main, report, search
```

Why each step
- `fetch --prune`: fetch only adds/moves `origin/*` names. `--prune` also removes the names whose
  branch no longer exists on origin. (Same thing later: `git remote prune origin`.)
- `git switch search`: shortcut for `git switch -c search --track origin/search`. Tracking =
  "upstream": the branch git compares with in `git status` and uses for plain `pull`/`push`.
- `git status` on main: "behind by 1, can be fast-forwarded" = origin has 1 commit you don't, you
  have none it doesn't. So pull just moves main forward, no merge commit. (`ahead 2, behind 1`
  would be diverged: then you'd need merge or rebase, see labs 06 and 09.)
- `git push -u origin report`: the first push of a new branch needs the names; `-u` stores the
  upstream so later just `git push`. Alternative after a push without `-u`:
  `git branch -u origin/report` (= `--set-upstream-to`).
- `git push origin --delete experiment` (old spelling: `git push origin :experiment`, "push
  nothing into experiment"). It's a push because it changes origin.

Common wrong attempts
- `git fetch` without `--prune` -> origin/old-ui stays forever in your `git branch -r`.
- `git branch -d experiment` / `git branch -dr origin/experiment` -> only touches your local
  repo; origin still has experiment (`git ls-remote origin` shows it), and the next fetch brings
  origin/experiment back.
- `git branch search` (or `git switch -c search`) while on report -> a new branch at *your*
  commit, not the teammate's, and with no upstream.
- `git push origin report` without `-u` -> report is on origin but `git branch -vv` shows no
  `[origin/report]`; fix with `git branch -u origin/report`.
- Running `git pull` while still on report -> report has no upstream yet: "There is no tracking
  information for the current branch."
