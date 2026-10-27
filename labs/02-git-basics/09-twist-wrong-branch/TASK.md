# 09 - Twist: committed to main by mistake

```
$ git log --graph --oneline --all --decorate
* xxxxxxx (HEAD -> main) Validate login fields
* xxxxxxx Add login form
* xxxxxxx Add greet

$ git status
On branch main
nothing to commit, working tree clean
```
The two login commits should have been on a branch called `login`. Nothing has been pushed.

## Task
1. Put both login commits on a new branch `login`.
2. Move main back so it only has "Add greet".
3. End on `login`.

## Stop
Do not re-create the commits by hand (no new commits at all). Do not lose the login work.

## What will be checked
- main has 1 commit ("Add greet"), no login.py at main
- login exists with 3 commits, tip "Validate login fields"
- on login, clean tree
