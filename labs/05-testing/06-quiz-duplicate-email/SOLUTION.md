# Solution - 06-quiz-duplicate-email

Add to `test_signup.py`:
```python
def test_signup_rejects_duplicate_email():
    # Arrange
    repo = FakeUserRepo()
    signup(repo, "user@example.com")          # first signup: 201
    # Act
    status = signup(repo, "user@example.com")  # same email again
    # Assert
    assert status == 409
    assert repo.count() == 1
```
```bash
pytest                                  # 1 failed: assert 201 == 409  (red = bug reproduced)
git add test_signup.py
git commit -m "Add failing test for duplicate email signup"
```
Fix `signup.py`, inside `signup` before `repo.save(email)`:
```python
    if repo.find(email) is not None:
        return 409
```
```bash
pytest                                  # 3 passed
git add signup.py
git commit -m "Return 409 for duplicate email signup"
git log --oneline                       # 3 commits
cd .. && ./check.sh
```

Why a fake and not a mock: with a Mock, `save` is recorded but nothing is stored, so `find` can never
see the first user; you could only assert "save was called". The fake really stores users, so the
test checks behaviour (status code + stored once). This is quiz 2 Q2's point.

Common wrong attempts:
- Checking the duplicate *after* `repo.save` -> the first signup already finds itself -> returns 409 on the first call; test_signup_creates_user goes red.
- `git commit -am "..."` for commit 1 while signup.py is already edited -> fix lands in the test commit.
- Test asserts `status != 201` -> passes for 500 too; assert the exact 409.
