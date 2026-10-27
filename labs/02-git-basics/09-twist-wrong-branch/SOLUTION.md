# Solution 09

Key idea: a branch is just a pointer. The commits are fine; only the labels are wrong.

```bash
git branch login           # new label on the current commit (keeps the 2 login commits)
git reset --hard HEAD~2    # move main (the current branch) back 2 commits; working dir follows
git switch login           # go to the branch that has the work
git log --oneline --graph --all --decorate
```

Alternative without reset (move the other label instead):
```bash
git switch -c login        # create + switch; the commits come with you
git branch -f main HEAD~2  # force the main label to point 2 commits back
```

`HEAD~2` = "two commits before HEAD". `reset --hard` also overwrites the working directory and
staging, so only use it on a CLEAN tree (here it is). Reset modes (--soft/--mixed/--hard) are
covered in the git-history topic.

## Common wrong attempts
- `git switch -c login` then `git reset --hard HEAD~2`: you reset LOGIN (the current branch), not main.
  Recover: `git reset --hard ORIG_HEAD` (or use the reflog).
- `git reset --hard HEAD~2` BEFORE creating the branch: the commits have no label. Recover with
  `git branch login ORIG_HEAD` or find them in `git reflog`.
- `git branch -f main HEAD~2` while ON main: "fatal: cannot force update the current branch".
