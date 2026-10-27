# 14 - Twist: hotfix an old release (detached HEAD) + read git's objects

```
$ git log --oneline --decorate
xxxxxxx (HEAD -> main) Add texts, tune config
xxxxxxx Start v2
xxxxxxx (tag: v1.0) Add readme
xxxxxxx Add app and config

$ git status
On branch main
nothing to commit, working tree clean
```
Context: a customer still runs release `v1.0` (an annotated tag). In v1.0, config.py is
`RETRIES = 0`, which breaks them. main has moved on (v2 work) and must not change.

## Task
Part A: hotfix the old release
1. Check out the commit that `v1.0` points to. Git will say you are in **'detached HEAD'** state:
   HEAD points at a commit, not at a branch.
2. Make config.py exactly `RETRIES = 3` and commit it with message `Fix retries for 1.0`.
3. Save that commit on a new branch called `v1-hotfix` (it must contain v1.0's history + your fix only).
4. Go back to main.

Part B: look inside the object database. Create a file `answers.txt` (it is git-ignored for you)
with exactly three lines:
1. the hash of the **tree** that your v1-hotfix commit points to (full hash or at least 7 chars)
2. the object **type** of `v1.0` (one word)
3. the name of the other file in main's tree that has the **same blob hash** as `banner.txt`

Hints:
- `git cat-file -p <thing>` prints an object's content; `git cat-file -t <thing>` prints its type.
  `<thing>` can be a hash, a branch name or a tag name. `main^{tree}` means "the tree of main's commit".
- Order matters in Part A: if you leave the detached commit before giving it a branch, no branch
  points to it. Git prints a warning with its hash; you could still rescue it with
  `git branch v1-hotfix <hash>`.
- Write answers.txt with your editor, or with `echo ... >> answers.txt` one line at a time.

## Stop
Don't touch main or the v1.0 tag. One commit only (the fix). Don't merge v1-hotfix anywhere.

## What will be checked
- v1-hotfix: 3 commits, its parent is v1.0's commit, only config.py changed, `RETRIES = 3`
- main unchanged; v1.0 unchanged; you're on main (not detached); clean tree
- answers.txt lines 1-3 correct
