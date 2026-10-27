# Solution 14

```bash
git push                                # ! [rejected] main -> main (fetch first)
git fetch                               # * [new branch] release-1.0 -> origin/release-1.0
                                        #   c610ed6..9d1e2f3  main -> origin/main
git status                              # have diverged, 2 and 1 different commits each
git log --oneline main..origin/main     # Add wishlist                  (theirs)
git log --oneline origin/main..main     # Add dark mode, Fix price rounding (yours)
git rebase origin/main                  # replay your 2 commits on top of "Add wishlist"
                                        # (same as: git pull --rebase)
git push                                # fast-forward now
git log --oneline | grep "price rounding"   # e.g. 7a7b7c7 Fix price rounding
git switch release-1.0                  # creates local branch, tracking origin/release-1.0
git cherry-pick 7a7b7c7                 # copy just the fix (new commit on release-1.0)
git push                                # upstream is set, so plain push goes to origin/release-1.0
git switch main
```

Why each step
- `git push` rejected: origin's main has "Add wishlist", which your main doesn't contain, so
  accepting would drop it. Push only moves a remote branch **forward**.
- `git fetch`: downloads both the new main commit and the new branch. Only now does
  `origin/release-1.0` exist in your repo, so only now can `git switch release-1.0` find it.
- `A..B` = "commits reachable from B but not from A". `main..origin/main` = what you're missing,
  `origin/main..main` = what you'd be pushing. Ahead 2 / behind 1 = diverged.
- `git rebase origin/main`: your two unpushed commits get new hashes on top of the teammate's;
  history stays a line. Safe because they were never pushed. No conflict: different files.
- `git cherry-pick <hash>`: applies the *change* of that one commit onto the current branch as a
  new commit. Merging main into release would drag in wishlist and dark mode (features).
- Plain `git push` on release-1.0 works because `git switch` set the upstream.

Common wrong attempts
- `git switch release-1.0` before fetching -> `fatal: invalid reference: release-1.0`.
- `git switch -c release-1.0` -> a NEW branch at your main (has dark mode!), not origin's release;
  pushing it gets rejected (or, with force, wrecks the release).
- `git merge main` (or `git merge origin/main`) on release-1.0 -> features land on the release.
- `git pull` / `git pull --no-rebase` on main -> a merge commit; the "linear" check fails.
- `git push --force` on main -> erases "Add wishlist" from origin.
- `git cherry-pick` the dark-mode hash too, or cherry-picking while still on main
  (-> "The previous cherry-pick is now empty", or a duplicate commit on main).
- Forgetting to switch back -> the "on main" check fails.
