# Solution 04

```bash
git mv utils.py helpers.py        # rename on disk AND stage the rename in one go
git rm old_notes.txt              # delete on disk AND stage the deletion
git rm --cached .env              # remove from the staging area only; file stays on disk
```

Editor: Files panel -> **+ New file** -> `.gitignore`, type the line below, save with Ctrl+S.
Why: a future `git add .` will skip `.env`.
```
.env
```

```bash
git add .gitignore
git status                        # renamed / deleted / deleted(.env) / new file .gitignore
git commit -m "Tidy repository"
```

Why `--cached`: plain `git rm .env` deletes the file from disk too. `--cached` = "only from the index".
Note: the password is still inside the OLD commits. For a real leak you must also rotate the secret.

## Common wrong attempts
- `mv utils.py helpers.py` (plain mv) then commit: git sees utils.py deleted (unstaged) and helpers.py
  untracked; nothing is staged. Fix: `git add -A` (stages deletions and new files).
- `git rm .env`: file is gone from disk (check fails). Recover: `git restore --staged .env && git restore .env`
  before committing, then use `--cached`.
- Adding `.env` to .gitignore without `git rm --cached`: .gitignore only affects UNTRACKED files.
  A tracked file stays tracked.
