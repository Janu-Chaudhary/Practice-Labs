# 05 · Quiz-style · Lost detached commit (quiz 1, Question 19)

```
$ git log --graph --oneline --all --decorate
* 0f9523b (HEAD -> main) Add README
* e8bf956 (origin/main) Add request handler

$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```
(Your hashes will differ from these and from the quiz. The checks use commit messages.)

**Context:** you're on local `main`, which has two commits: "Add request handler", then
"Add README". Only "Add request handler" has been pushed, so main is one commit ahead of
`origin/main`. Nothing is staged, modified or untracked.

Earlier, you checked out "Add request handler" directly by its hash (detached HEAD), added
`limits.py`, and committed it with message "Add rate limit config". Then you switched back to
`main`.

**Issue:** no branch points to that commit, so `git log` doesn't show it, and `limits.py` isn't
in your folder.

**Task:**
1. Find the commit with message "Add rate limit config" (`git reflog` lists where HEAD has been).
2. Create a branch called `rate-limit` pointing at that commit.
3. Merge `rate-limit` into `main`. (No merge message required.)
4. Push local `main` to `origin/main`.

**Stop:** don't push rate-limit, don't delete it, and make no other commits.

**Hints**
- use `grep` and `|` to filter the reflog.
- `git branch` shows the branches and which one you're on.
- `git merge rate-limit` makes a merge commit and opens an editor for its message. Save and close it
  (nano: Ctrl+O Enter Ctrl+X; vim: `:wq`), or skip the editor with `git merge --no-edit rate-limit`.

**What will be checked**
- rate-limit is the commit "Add rate limit config"
- rate-limit is merged into main
- main has 4 commits
- main is pushed to origin (and rate-limit is not)
