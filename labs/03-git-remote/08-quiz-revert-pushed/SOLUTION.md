# Solution 08

```bash
git log --oneline | grep "Disable auth"   # 0866799 Disable auth check
git show 0866799                          # see what it changed (- is_logged_in / + True)
git revert --no-edit 0866799              # YOUR hash. New commit: Revert "Disable auth check"
cat auth.py                               # return user.is_logged_in
git push
```

Why revert: `git revert <hash>` makes a NEW commit that applies the opposite of `<hash>`'s diff.
History only grows, so everyone who already pulled can just pull again. `reset` instead moves the
branch pointer backwards, which rewrites history: the next push is rejected (non-fast-forward) and
forcing it breaks every teammate's copy.

Common wrong attempts
- `git reset --hard HEAD~2` -> also throws away "Add order totals", and the push is rejected
  (your main is now *behind* origin/main). Forcing it would erase pushed work.
- `git revert HEAD` -> reverts "Add order totals" (the wrong commit).
- Editing auth.py by hand and committing -> works for the code, but the check expects the revert
  commit message (and in real life revert also documents *which* commit was undone).
- `git revert` without `--no-edit` opens an editor; save and close to finish.
