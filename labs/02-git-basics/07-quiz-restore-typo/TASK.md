# 07 - Quiz-style: discard only the unstaged typo (recreates Quiz 1 Q12)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add config

$ git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   config.py

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   config.py
```
The last commit has `TIMEOUT = 30` in config.py. You changed that to `TIMEOUT = 60` and staged it.
Later you mistyped, and config.py in the working directory now has `TIMEOUT = 6000`.

## Task
1. Prove it to yourself: compare `git diff` and `git diff --staged`. Which shows 30 -> 60 and which 60 -> 6000?
2. Throw away **only** the unstaged typo, leaving `TIMEOUT = 60` staged and in the working directory.

## Stop
Do not commit. Do not unstage the 60.

## What will be checked
- HEAD still has 30 (no commit); staging area has 60; working directory has 60
- git diff empty, git diff --staged not empty
