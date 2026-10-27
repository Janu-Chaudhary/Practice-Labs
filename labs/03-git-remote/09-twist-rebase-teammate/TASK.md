# 09 · Twist · Teammate pushed first, and the team wants a linear history

```
$ git log --graph --oneline --all --decorate
* f3f1761 (HEAD -> main) Add search endpoint
* 3c8572b (origin/main) Add orders route

$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)
```

**Context:** you committed "Add search endpoint" (adds `GET /search` to routes.txt). `git status`
looks happy, but it only compares with the origin/main you downloaded last time. Meanwhile a
teammate pushed "Add health endpoint", which added `GET /health` on the same line position.

Team rule: main must stay **linear: no merge commits**.

**Task:**
1. Try `git push`, read the rejection.
2. Put your commit on top of the teammate's commit **with a rebase**, not a merge.
3. You will hit a conflict in routes.txt. Resolve it so the file is exactly:
   ```
   GET /orders
   GET /health
   GET /search
   ```
4. Finish the rebase and push.

**Stop:** no force push, no merge commit, make no other commits.

**Hints:** `git pull --rebase` = fetch + rebase onto origin/main. During a rebase conflict:
edit the file, `git add` it, then `git rebase --continue` (it may open an editor for the commit
message: save and close). Panic button: `git rebase --abort` puts everything back.

**What will be checked**
- teammate's "Add health endpoint" kept as-is
- main has no merge commits, 3 commits, yours on top
- routes.txt at main is exactly orders / health / search
- no rebase in progress; remote main == local main
