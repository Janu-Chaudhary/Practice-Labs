# 11 - Quiz-style: amend the last commit (typo + forgotten file)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add setings loader
xxxxxxx Add greet

$ git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   todo.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        settings.json
```
Context: you just committed loader.py as "Add setings loader". Two problems: the message has a
typo, and you forgot `settings.json` (loader.py reads it). Nothing has been pushed.
Separately, you staged a private note in todo.txt by accident. That note must never be committed.

## Task
1. Take todo.txt **out of the staging area**, but keep your edit in the file on disk.
2. Fix the last commit so that it **also contains settings.json** and its message is exactly
   `Add settings loader`. Do this by changing the last commit, not by adding a new one.

Hints:
- `git commit --amend` replaces the last commit with a new one built from the staging area.
  It takes **everything that is staged right now**, so think about the order of your steps.
- `git commit --amend` without `-m` OPENS AN EDITOR (vim: `Esc :wq Enter`). Use `-m "..."` to skip it.

## Stop
main must have exactly 2 commits. Do not commit todo.txt. Do not throw away your todo.txt edit.

## What will be checked
- main has 2 commits: "Add greet", then "Add settings loader" (no "Add setings loader" on main)
- the last commit contains loader.py and settings.json
- todo.txt at main is unchanged; todo.txt on disk still has the private line
- `git status --porcelain` shows only ` M todo.txt` (modified, not staged)
