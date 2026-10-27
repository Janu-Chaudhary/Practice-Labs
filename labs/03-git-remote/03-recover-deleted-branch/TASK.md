# 03 · Drill · Bring back a branch deleted with `git branch -D`

```
$ git log --graph --oneline --all --decorate
* 6d726f5 (HEAD -> main) Add app

$ git branch -D payments
Deleted branch payments (was 6c4f777).
```

**Context:** you had a branch `payments` with two commits on top of `main`: "Add payment model"
and "Add refund handler". You deleted it by mistake with `git branch -D` (capital D = delete even
if it was never merged). The terminal output with the hash has scrolled away.

A branch is only a pointer (a small file holding a hash). Deleting it removed the pointer, not the
commits. The commits are still in `.git/objects`, and `git reflog` remembers them.

**Task:**
1. Find the hash of the commit "Add refund handler" (use `git reflog`, filter with `grep`).
2. Recreate branch `payments` pointing at that commit.

**Stop:** stay on `main`, don't merge, don't make commits.

**What will be checked**
- payments exists and is the commit "Add refund handler" (3 commits)
- you are on main; main still has 1 commit
