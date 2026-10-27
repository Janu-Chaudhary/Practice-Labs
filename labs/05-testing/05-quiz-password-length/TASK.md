# 05-testing / 05 - Quiz 2 Q16: failing test, then fix  (Quiz-style)

```
$ git log --oneline
b8b4933 (HEAD -> main) Add password length check
$ git status
On branch main
nothing to commit, working tree clean
$ ls
test_validate.py  validate.py
```

## Context
You're on `main`, with one commit. A password needs **at least 8** characters, but
`is_valid_length("abcdefgh")` in `validate.py` returns `False`.

## Task
Fix it in **exactly two commits** (run `pytest` before each commit):
1. A test that catches the bug. Its commit message contains `failing test`.
2. Find and fix the bug in `validate.py`.

Note: run pytest to see your test fail, then pass. Made an extra commit?
`git reset --soft HEAD~1` undoes the last commit and keeps your changes.

## Stop
Done when main has exactly your two commits on top of the current one, and pytest passes. Don't push.

## What will be checked
- test_validate.py at HEAD~1 contains "abcdefgh"
- validate.py at HEAD~1 has the original content
- HEAD~1 commit message matches "failing test"
- HEAD has 3 commits
- test_validate.py has at least 3 tests, all passing at HEAD
- (extra, this lab only) pytest really fails at HEAD~1
