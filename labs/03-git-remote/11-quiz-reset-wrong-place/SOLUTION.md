# Solution 11

```bash
git reflog
# 807663c HEAD@{0}: commit: Fix typo in README
# 98ef414 HEAD@{1}: reset: moving to origin/main      <- the mistake
# d2cf3a7 HEAD@{2}: commit: Add discount               <- where main was before it
# 8b8f9cb HEAD@{3}: commit: Add cart
git reflog | grep "Add discount"      # just that line, copy the hash (d2cf3a7 here)
git rebase d2cf3a7                    # replay "Fix typo in README" on top of "Add discount"
git log --oneline --graph             # 5 commits, straight line, typo fix on top
ls                                    # cart.py and discount.py are back
git push                              # origin/main (Add README) is an ancestor: fast-forward
```

Why each step
- `git reflog`: `git log` only walks back from main, and main no longer reaches the two commits.
  The reflog is a diary of where HEAD pointed, so it still lists them.
- `git rebase d2cf3a7`: rebase takes the commits on main that are **not** in d2cf3a7's history
  (only "Fix typo in README"; Add app/Add README are already in it), moves main to d2cf3a7, and
  replays the typo fix on top. Cart and discount keep their original hashes because they are not
  replayed; the typo fix gets a new hash (new parent). Safe: none of these were pushed.
- `git push`: the remote has "Add README"; your new main contains it, so it's a normal push.

Equivalent route (reset + cherry-pick):
```bash
git reset --hard d2cf3a7              # main back to "Add discount" (typo fix leaves main...)
git reflog | grep "Fix typo"          # ...but the reflog still has it, e.g. 807663c
git cherry-pick 807663c               # copy it on top
git push
```
(`git reset --hard HEAD@{2}` also works instead of the hash: HEAD@{2} = "two moves ago". Count
carefully, every commit/reset/switch is one move.)

Common wrong attempts
- `git reset --hard d2cf3a7` and stop -> cart and discount back, but "Fix typo in README" is gone
  from main: 4 commits, README still "Ordres".
- `git merge d2cf3a7` -> a merge commit (6 commits, not a straight line).
- `git cherry-pick 8b8f9cb d2cf3a7` on top of the typo fix -> right files, but **new** hashes and
  wrong order (typo fix in the middle). The "original commits" check fails.
- Writing cart.py/discount.py again from memory and committing -> new commits, not the originals.
- `git push --force` at any point -> not needed: origin never had cart/discount, and the history
  you push contains origin/main.
