# 04 - git mv, git rm, git rm --cached, .gitignore (Drill)

## Situation
```
$ git log --oneline
xxxxxxx (HEAD -> main) Add env
xxxxxxx Add notes
xxxxxxx Add utils
$ ls -a
.  ..  .env  .git  old_notes.txt  utils.py
```
Someone committed `.env` (a secret). The team also wants `utils.py` renamed to `helpers.py` and
`old_notes.txt` deleted.

## Task
In **one** commit with message `Tidy repository`:
1. Rename `utils.py` to `helpers.py` using git.
2. Delete `old_notes.txt` using git.
3. Stop tracking `.env` but **keep the file on disk** (your app still needs it).
4. Add a `.gitignore` with the line `.env` so it never gets staged again.

## Stop
Exactly one new commit. `.env` must still exist locally.

## What will be checked
- main has 4 commits, latest "Tidy repository"
- helpers.py at HEAD; utils.py and old_notes.txt gone (HEAD and disk)
- .env not at HEAD but still on disk; .gitignore has `.env`; clean tree
