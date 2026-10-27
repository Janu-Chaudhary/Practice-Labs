# Solution - 07-quiz-undo-extra-commit

```bash
git log --oneline              # 4 commits, wip on top
git show --stat HEAD           # what the wip commit changed: notes.txt, grade.py
git reset --soft HEAD~1        # move main back one commit; the wip changes stay STAGED
git status                     # notes.txt "new file", grade.py "modified" - both staged
git restore --staged notes.txt grade.py   # unstage both (files keep their content)
git restore grade.py           # throw away the debug print in the working folder
git status                     # only: Untracked files: notes.txt
pytest
cd .. && ./check.sh
```

The three resets (all move the branch pointer back):
- `git reset --soft HEAD~1`  : undo the commit, keep changes **staged**.
- `git reset HEAD~1` (= `--mixed`): undo the commit, keep changes but **unstaged**. One step shorter here:
  then just `git restore grade.py`.
- `git reset --hard HEAD~1`  : undo the commit and **delete** the changes -> notes.txt is gone. Fails check 4.

Common wrong attempts:
- `git revert HEAD` -> adds a new commit that undoes wip -> 5 commits, fails.
- `git reset --soft HEAD~1` then `git commit --amend` -> folds notes.txt + print INTO the fix commit; new ID, fails.
- `git rm notes.txt` -> deletes the file from disk too; use `git rm --cached notes.txt` (keeps it) or `git restore --staged`.
- Forgetting `git restore grade.py` -> DEBUG line still in the file.

Tip: to stop notes.txt showing as untracked forever, you could add it to `.gitignore` (not required here).
