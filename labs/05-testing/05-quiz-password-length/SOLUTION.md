# Solution - 05-quiz-password-length

```bash
cat validate.py                       # see the bug: len(password) > 8  (8 is NOT > 8)
pytest                                # 2 passed - the existing tests miss the boundary
code test_validate.py                 # add the test below, save
```
```python
def test_accepts_exactly_eight_characters():
    assert is_valid_length("abcdefgh") is True
```
```bash
pytest                                # 1 failed, 2 passed  -> red: the test catches the bug
git add test_validate.py              # ONLY the test file
git commit -m "Add failing test for 8-character password"
code validate.py                      # change  > 8  to  >= 8
pytest                                # 3 passed -> green
git add validate.py
git commit -m "Fix password length check to accept 8 characters"
git log --oneline                     # 3 commits: fix, failing test, original
cd .. && ./check.sh
```

Why the order matters: commit 1 is the evidence that the bug existed (the test is red there);
commit 2 is the smallest change that turns it green. The grader looks at HEAD~1 (the test commit)
and HEAD (the fix).

Common wrong attempts and what they cause:
- Fixing validate.py and adding the test in one commit -> only 2 commits; HEAD~1 is the original; most checks fail.
- `git add .` after editing both files -> the "test" commit also contains the fix -> "validate.py at HEAD~1" fails.
- Fix first, test second -> HEAD~1 has a changed validate.py and its message is not "failing test".
- Message "add test" -> does not match "failing test".
- A third commit (e.g. a typo fix) -> "HEAD has 3 commits" fails. Undo it: `git reset --soft HEAD~1`
  (keeps the changes staged), then `git commit --amend` to fold them into the fix commit,
  or `git restore --staged . && git restore .` to throw them away.
- Typo in the message of the LAST commit -> `git commit --amend -m "new message"` rewrites it (only before pushing).
