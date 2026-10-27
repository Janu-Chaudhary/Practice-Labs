# Solution 09

```bash
git push                    # ! [rejected] main -> main (fetch first)
git pull --rebase           # CONFLICT (content): Merge conflict in routes.txt
git status                  # interactive rebase in progress; both modified: routes.txt
```

Editor: open `routes.txt` in the Files panel (it shows the conflict, see below). Delete the
`<<<<<<<`, `=======` and `>>>>>>>` lines, keep all three routes in this order, save with Ctrl+S:
```
GET /orders
GET /health
GET /search
```

Back in the terminal:
```bash
grep -n '<<<<<<<\|=======\|>>>>>>>' routes.txt   # prints nothing = no markers left
git add routes.txt          # mark the conflict resolved
git rebase --continue       # terminal editor opens with "Add search endpoint": vim :wq Enter
                            # (non-interactive: GIT_EDITOR=true git rebase --continue)
git log --oneline --graph   # straight line: search -> health -> orders
git push
```

What the conflict looks like during a rebase (note: HEAD = the commit you're replaying ONTO,
i.e. the teammate's side; the bottom part is your commit being replayed):
```
GET /orders
<<<<<<< HEAD
GET /health
=======
GET /search
>>>>>>> f3f1761 (Add search endpoint)
```

Same thing in two steps: `git fetch` then `git rebase origin/main`.

Why: rebase takes your unpushed commit, sets it aside, moves main to origin/main, then replays your
commit on top (new hash). Your main now contains origin/main, so the push is a fast-forward.
It's safe because your commit was never pushed; you never rebase commits others have.

Common wrong attempts
- `git pull --no-rebase` -> merge commit; the "linear" check fails.
- Forgetting `git add` before `--continue` -> `error: ... you must edit all merge conflicts and
  then mark them as resolved using git add`.
- `git commit` during the rebase instead of `git rebase --continue` -> leaves the rebase in progress.
- `git push --force` -> erases teammate's "Add health endpoint" from origin.
