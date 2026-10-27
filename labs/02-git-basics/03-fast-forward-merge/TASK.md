# 03 - fast-forward merge (Drill)

## Situation
```
$ git log --oneline --graph --all --decorate
* xxxxxxx (feature) Test sub()
* xxxxxxx Add sub()
* xxxxxxx (HEAD -> main) Add add()
```
main has made no new commits since feature branched off.

## Task
1. Before running anything, predict: will merging feature into main make a merge commit? Why?
2. Merge feature into main.
3. Look at the graph again. Where is main now?

## Stop
Do not delete feature. Do not create any extra commit (no `--no-ff`).

## What will be checked
- feature merged into main, main == feature, main has 3 commits, no merge commit
- feature still exists, on main, clean tree
