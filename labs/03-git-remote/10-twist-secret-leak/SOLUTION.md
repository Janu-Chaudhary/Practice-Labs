# Solution 10

```bash
git log --all --oneline -- .env          # every commit that touched .env (newest first):
                                         # cfc90e8 Remove env file / 677777a Add config loader
git log --all --oneline --diff-filter=A -- .env   # only the commit that Added it: 677777a
git branch leak 677777a                  # YOUR hash
git show 677777a:.env                    # DB_PASSWORD=Summer2024!  (file as it was in that commit)
```

Editor: Files panel -> **+ New file** -> `.gitignore`, type this one line, save with Ctrl+S.
Why: git will now skip `.env` in `git status` and `git add .`.
```
.env
```

```bash
git add .gitignore
git commit -m "Ignore .env"
git status                               # .env no longer listed as untracked
git check-ignore -v .env                 # .gitignore:1:.env  .env  -> proof it's ignored
```

Is the password safe after "Remove env file"? **No.** Deleting the file only makes a new snapshot
without it. Every older commit still contains `.env`, and anyone with a clone can run
`git show 677777a:.env`. If it was pushed, assume it's public. The fix is to **rotate** the password
(change it at the database, so the leaked one stops working) first. Rewriting history afterwards
(e.g. git filter-repo) is optional clean-up and doesn't help copies that already exist.

Notes
- `-- .env` means "only commits that touched this path". The `--` separates paths from branch names.
- `git log --all --full-history -- .env` (from the lecture) proves a file was NEVER committed when
  it prints nothing.
- `git show <hash>:<path>` prints a file from any commit without changing your folder.
  `git show <hash>` shows the whole commit (message + diff).

Common wrong attempts
- `git add .` then commit -> commits your local .env too. (Check with `git status` before commit.)
- Naming the new file `gitignore` (no dot) -> git doesn't read it, `git status` still lists `.env`.
  The name must be exactly `.gitignore`.
- Adding .gitignore AFTER `git add .env` -> .gitignore doesn't untrack files already staged/tracked.
