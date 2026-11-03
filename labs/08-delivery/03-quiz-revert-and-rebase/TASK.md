# 03 - Roll back by reverting the commit, while a teammate pushed (Quiz-style)

```
$ git log --oneline
c41e9a2 (HEAD -> main, origin/main) Update footer text
7d02b1f Add group orders
1a8e33c Add checkout

$ git status
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

**Context:** "Add group orders" broke checkout for customers without a saved group. It was pushed,
and the pipeline deployed it. After it came a good commit, "Update footer text". The team decides
to go back **by reverting the commit** (the slow-but-permanent way back: the pipeline then rebuilds
and redeploys from main).

Careful: `git status` says "up to date", but that only compares with the last time you fetched.
A teammate has pushed since then.

**Task** (inside `work/`):
1. Undo **only** the changes of "Add group orders" with **one new commit** whose message is exactly
   `Roll back group orders`. Keep "Update footer text".
2. Ship it to `origin/main`. The team wants main to stay a **straight line: no merge commits**.

**Done when:** main and origin/main point to the same commit, history has exactly 5 commits, the
newest is `Roll back group orders`, and the teammate's commit is kept.

**Stop rules:** don't force-push, don't reset/rebase away pushed commits, don't edit `app.py` by hand.

**Hints**
- `git revert <hash>` makes a new commit that does the opposite of `<hash>`. Its default message is
  `Revert "..."` and it opens an editor. `--no-commit` (or `-n`) applies the undo but lets you write
  the commit yourself.
- Careful: `git revert -m` does **not** mean "message" (it picks a parent of a merge commit).
- When `git push` is rejected with `fetch first`, someone pushed before you. Put your commit on top
  of theirs: `git pull --rebase`. Plain `git pull` may make a merge commit.
- If anything goes wrong: `git status` tells you what is in progress (`git revert --abort`,
  `git rebase --abort`).

**What will be checked**
- 5 commits, no merge commits, newest is exactly `Roll back group orders`, right after the teammate's commit
- `app.py` has no group code and keeps `TIMEOUT_SECONDS = 30`; `footer.txt` change kept
- "Add group orders" is still in history; local main == origin/main; nothing in progress, tree clean
