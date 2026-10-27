# Solution 07

```bash
git switch feature
git rebase main                     # Successfully rebased and updated refs/heads/feature.
git log --graph --oneline --all     # a straight line: README, changelog, notes, strip
ls                                  # CHANGELOG.md  README.md  notes.py
```

Why new hashes: a commit's id is a hash of (snapshot tree + parent hash + author/time + message).
Rebase *replays* each feature commit with a new parent ("Update changelog"), so every replayed
commit is a NEW object with a NEW id. The old commits are not deleted right away; they're still in
the reflog (`git reflog` shows `rebase (pick): Add notes`) until git's garbage collection removes
them. main does not move: rebase only rewrites the branch you're on.

Merge vs rebase vs squash
- `git merge main` (on feature): keeps the original commits, adds a merge commit with two parents.
  History shows the real branch shape. Safe on shared branches.
- `git rebase main`: rewrites your commits on top of main, linear history, no merge commit, new
  hashes. Don't rebase commits other people already pulled.
- Squash (`git merge --squash feature` then `git commit`): puts all the changes of feature into ONE
  new commit on main; the feature commits themselves are not in main's history.

Common wrong attempts
- Running `git rebase main` while on main -> "Current branch main is up to date." nothing happens.
- `git rebase feature` while on main -> moves main on top of feature (main moves; check fails).
- `git merge main` on feature -> 5 commits incl. a merge commit; "no merge commit" check fails.
