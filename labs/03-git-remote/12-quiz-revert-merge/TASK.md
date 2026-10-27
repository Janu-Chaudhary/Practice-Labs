# 12 · Quiz-style (hard) · Undo a whole merged feature that's already pushed

```
$ git log --graph --oneline --all --decorate
* 53ad8bb (HEAD -> main, origin/main) Add logging config
*   2ceabd1 Merge branch 'discount'
|\
| * a7beb8f Use discount at checkout
| * 7a4d628 Add discount module
* | f5264a0 Add README
|/
* 2aef86e Add app

$ git status
On branch main
Your branch is up to date with 'origin/main'.
```
(Your hashes will be different.)

**Context:** the `discount` branch (2 commits) was merged into main and pushed. After it came a
good commit, "Add logging config". Now checkout charges the wrong price, and the team decides to
take the **whole discount feature** out for now. Teammates have already pulled main. The
`discount` branch itself was deleted after the merge.

**Task:**
1. Undo everything the merge brought into main (discount.py and the change to app.py) with **one
   new commit**, without rewriting history. Keep README.md and logging.cfg.
2. Push main to origin.

**Hints:**
- Reverting one normal commit at a time would need two reverts (two commits). There is one commit
  that represents the whole feature landing on main.
- A merge commit has **two parents**. If you revert it, git asks: *which parent is "main line"?*
  Try it without the option first and read the error. Look at the parents with
  `git log -1 --format=%P <hash>` or `git show <hash>` (line `Merge: a b`).
- The revert opens an editor for the message; `--no-edit` keeps git's default message.

**Stop:** no force push, no `reset`, exactly one new commit, don't touch README.md or logging.cfg.

**What will be checked**
- old pushed tip is still in main; main has 7 commits, the last one is not a merge
- last commit is `Revert "Merge branch 'discount'"`
- discount.py gone; app.py identical to the version in "Add app"
- README.md and logging.cfg still in main
- remote main == local main
