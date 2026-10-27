# 08 - Quiz-style: stash, merge, pop

```
$ git log --graph --oneline --all --decorate
* xxxxxxx (HEAD -> main) Add app
| * xxxxxxx (feature) Rename notes heading
|/
* xxxxxxx Add notes

$ git status
On branch main
Changes not staged for commit:
        modified:   notes.txt
```
You are halfway through adding a line to notes.txt (not ready to commit). Your lead asks you to merge
feature into main **now**.

## Task
1. Try `git merge feature` and read the error.
2. Put your unfinished edit aside, merge feature into main (main has its own commit, so this makes a
   merge commit; avoid getting stuck in the editor), then bring your edit back.

## Stop
Do not commit your WIP line. Leave the stash empty. Do not delete feature.

## What will be checked
- feature merged; main has 4 commits; tip has 2 parents
- notes.txt at main has the v2 heading and no WIP line
- notes.txt on disk has both; only change in `git status` is ` M notes.txt`; stash list empty
