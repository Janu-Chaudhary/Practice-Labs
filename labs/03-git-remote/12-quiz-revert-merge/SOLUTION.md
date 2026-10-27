# Solution 12

```bash
git log --oneline | grep Merge            # 2ceabd1 Merge branch 'discount'
git revert 2ceabd1                        # try it: error, see below
git show 2ceabd1 | head -3                # Merge: f5264a0 a7beb8f   (parent 1 = main side)
git revert -m 1 --no-edit 2ceabd1         # undo what the merge added, compared to parent 1
git log --oneline -3                      # Revert "Merge branch 'discount'" on top
ls                                        # no discount.py; cat app.py = original checkout()
git push                                  # new commit on top -> fast-forward push
```

The first try fails with:
```
error: commit 2ceabd1... is a merge but no -m option was given.
fatal: revert failed
```

Why each step
- `git revert` makes a **new** commit that does the opposite of an old one. History is only added
  to, so teammates who already pulled are fine and the push needs no force.
- `-m 1`: a merge commit has two parents. "Undo the merge" means: make the files look like
  **parent 1** again (the main side, "Add README"), i.e. remove everything that came in from
  parent 2 (the discount side). Parent 1 is always the branch you were *on* when you merged.
- Later commits ("Add logging config") don't touch those files, so they stay.
- `--no-edit` skips the editor; without it, save and close the editor that opens.

Common wrong attempts
- `git revert 2ceabd1` without `-m` -> the error above, nothing happens.
- `git revert -m 2 ...` -> keeps the discount feature and instead undoes "Add README" (the main
  side). The README check fails and discount.py is still there.
- Reverting `a7beb8f` and `7a4d628` separately -> works on the files, but 2 commits (8 total),
  and it is easy to do them in the wrong order (revert the newest first).
- `git reset --hard 2ceabd1~1` (or `HEAD~2`) + `git push --force` -> rewrites shared history and
  also throws away "Add logging config". Teammates' clones break.

Good to know (unseen-question bait): after reverting a merge, merging the *same* branch again
later does nothing, because git sees those commits as already merged. To bring the feature back
you revert the revert: `git revert <hash of the Revert commit>`.
