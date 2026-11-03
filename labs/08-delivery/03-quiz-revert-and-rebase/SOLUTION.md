# Solution - 03-quiz-revert-and-rebase

```bash
cd work
git log --oneline                                  # find "Add group orders", e.g. 7d02b1f
git show 7d02b1f                                   # YOUR hash: + GROUPS ..., + if group: ...
git revert --no-commit 7d02b1f                     # undo its changes, stage them, don't commit yet
git status                                         # "You are currently reverting commit 7d02b1f", app.py staged
git commit -m "Roll back group orders"             # finishes the revert with YOUR message
git push                                           # ! [rejected] main -> main (fetch first)
git pull --rebase                                  # fetch teammate's commit, replay yours on top of it
git log --oneline                                  # Roll back group orders / Raise timeout... / Update footer / Add group orders / Add checkout
cat app.py                                         # TIMEOUT_SECONDS = 30, no GROUPS
git push                                           # main -> main
git status                                         # up to date with 'origin/main'
```

Why each step:
- `git revert` instead of `reset`: the bad commit is **already pushed and deployed**. Revert adds a
  new commit, so history only grows: teammates just pull, and the pipeline rebuilds from main.
  `reset` would rewrite pushed history and need a force-push.
- `--no-commit` then `git commit -m "..."`: the task wants an exact message. Plain
  `git revert <hash>` would open an editor with `Revert "Add group orders"`. (In the editor you
  could also replace that line; in vim: `i`, edit, `Esc`, `:wq`.)
- `git push` rejected: origin has a commit you don't. Nothing is broken, git just refuses to
  lose the teammate's commit.
- `git pull --rebase` = `git fetch` + `git rebase origin/main`: your one local commit is
  re-applied **after** "Raise timeout to 30 seconds". No merge commit, so history stays a line.
  The two changes touch different lines of app.py, so there is no conflict.

Same result, other ways:
```bash
git revert --no-edit 7d02b1f && git commit --amend -m "Roll back group orders"   # amend is fine: not pushed yet
git fetch && git rebase origin/main && git push                                  # = pull --rebase + push
```
You could also `git pull --rebase` first and revert after; either order ends the same.

## Common wrong attempts
- `git revert -m "Roll back group orders" 7d02b1f` -> ``error: option `mainline' expects a number greater than zero``.
  `-m` is for reverting merges.
- `git revert HEAD` -> undoes "Update footer text", the wrong commit.
- `git revert --no-edit <hash>` and stopping there -> message `Revert "Add group orders"`: the
  message check fails (exactly what cost marks in Quiz 3 Q9: right code, wrong message).
- `git pull` (no `--rebase`) after the rejection -> a merge commit: 6 commits and not linear
  (this is what happened in Quiz 3 Q9). To recover before pushing:
  `git reset --hard ORIG_HEAD` (back to before the merge), then `git pull --rebase`.
- `git pull` on a machine with no `pull.rebase` setting -> `fatal: Need to specify how to reconcile
  divergent branches`. Nothing happened; run `git pull --rebase`.
- `git push --force` -> deletes the teammate's commit from origin. Forbidden.
- `git reset --hard HEAD~2` -> also throws away the footer commit, and the push is rejected.
- Editing app.py by hand and committing -> the content would match, but a revert documents which
  commit was undone, and the task asks for the revert.
