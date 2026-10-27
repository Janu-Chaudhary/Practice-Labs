# Solution 13

```bash
git status                       # "You have unmerged paths" - a merge is in progress
git merge feature
#   error: Merging is not possible because you have unmerged files.
#   fatal: Exiting because of an unresolved conflict.
git merge --abort                # cancel the experiment merge: index + files back to main's tip
git status                       # On branch main, nothing to commit, working tree clean
git merge feature
#   CONFLICT (content): Merge conflict in requirements.txt
cat requirements.txt
#   flask==3.0.0
#   requests==2.31.0
#   <<<<<<< HEAD
#   gunicorn==22.0.0
#   =======
#   pytest==8.2.0
#   >>>>>>> feature
code requirements.txt            # delete ONLY the 3 marker lines, keep both dependency lines, save
#   no-editor equivalent:
#   printf 'flask==3.0.0\nrequests==2.31.0\ngunicorn==22.0.0\npytest==8.2.0\n' > requirements.txt
grep -n '<<<<<<<\|=======\|>>>>>>>' requirements.txt   # no output = markers gone
git add requirements.txt         # mark resolved
git commit --no-edit             # finish the merge with git's own message
git log --oneline --graph --all --decorate
```

Why each step:
- `git merge --abort` is the only clean way out of a merge you don't want. It puts the staging
  area and the working files back to how they were before `git merge experiment` ran
  (main's tip), and deletes MERGE_HEAD (git's "a merge is in progress" note).
- Then `git merge feature` is a normal three-way merge: base "Add app", ours "Add gunicorn",
  theirs "Add pytest". Both sides inserted a line at the same place, so git marks a conflict.
- Keeping both = remove the markers, keep both halves. Order: HEAD (main, ours) part is on top.
- `git commit --no-edit` creates the merge commit (two parents: main's old tip, then feature).

## Common wrong attempts
- Resolving app.py and committing: you just merged experiment. Undo with `git reset --hard HEAD~1`
  (only before anything else is committed), then do the feature merge.
- `git reset --hard` instead of `--abort`: also works here (clears the merge), but it's the
  bigger hammer: it would also delete any other uncommitted work you had. `--abort` is the precise tool.
- Picking one side (`git checkout --ours requirements.txt` or `--theirs`): one dependency is lost.
- Deleting the `=======` line but leaving `<<<<<<< HEAD`: `git add` happily accepts it; the
  "no conflict markers" check fails. Always grep for markers before `git add`.
