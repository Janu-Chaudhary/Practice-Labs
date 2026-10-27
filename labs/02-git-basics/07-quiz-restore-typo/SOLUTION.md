# Solution 07

```bash
git diff            # working dir vs STAGING:  -TIMEOUT = 60  +TIMEOUT = 6000
git diff --staged   # staging vs LAST COMMIT:  -TIMEOUT = 30  +TIMEOUT = 60
git restore config.py   # copy the STAGED version back over the working-directory file
git status          # only "Changes to be committed: modified: config.py"
cat config.py       # TIMEOUT = 60
```

Why: `git restore <file>` overwrites the working directory from the staging area. The staging area
is untouched.

## The wrong options (all from the real quiz)
- `git restore --staged config.py`: unstages: staging goes back to 30, working keeps 6000. Wrong way round.
- `git reset --hard`: resets staging AND working dir to the last commit: you lose the 60 too.
- `git add config.py`: stages the typo 6000 (now both are 6000).
- `git checkout config.py`: old-style equivalent of `git restore config.py`; also correct.
