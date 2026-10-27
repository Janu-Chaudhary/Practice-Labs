# 13 - Twist: abort a wrong merge, then do the right one (keep both sides)

```
$ git log --graph --oneline --all --decorate
* xxxxxxx (HEAD -> main) Add gunicorn, bump to v2
| * xxxxxxx (experiment) Try experimental banner
|/
| * xxxxxxx (feature) Add pytest
|/
* xxxxxxx Add app

$ git status
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   app.py
```
Context: a teammate sat at your laptop and started merging the **wrong** branch (`experiment`)
into main. It hit a conflict in app.py and they walked away. `experiment` must never reach main.
What should be merged is `feature`.

On main, requirements.txt ends with `gunicorn==22.0.0`. On feature it ends with `pytest==8.2.0`.
Both lines were added at the same spot, so git can't pick: **both** must be kept.

## Task
1. Cancel the teammate's merge so main is back to "Add gunicorn, bump to v2" with nothing in progress.
2. Merge `feature` into main.
3. Resolve the conflict so requirements.txt is exactly (main's line first, then feature's):
   ```
   flask==3.0.0
   requests==2.31.0
   gunicorn==22.0.0
   pytest==8.2.0
   ```
4. Finish the merge without the editor (`git commit --no-edit`, or `-m "..."`).

Hints:
- Try `git merge feature` first and read the error. You can't start a second merge while one is
  in progress.
- In the conflict, "keep both" means: delete the three marker lines (`<<<<<<<`, `=======`,
  `>>>>>>>`) and keep the text from both halves.

## Stop
Don't fix app.py and commit (that would complete the experiment merge). No other commits.
Don't delete feature or experiment.

## What will be checked
- no merge in progress; experiment NOT merged; feature merged
- main has 4 commits; tip is a merge commit whose second parent is feature
- requirements.txt at main exactly as above; app.py at main says "Shop v2"
- no conflict markers; on main, clean tree; both branches still exist
