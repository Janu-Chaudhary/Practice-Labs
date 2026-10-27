# Solution - 06-quiz-duplicate-email

In the Files panel open `test_signup.py` and add the new test at the end, so it reads:
```python
from signup import FakeUserRepo, signup


def test_signup_creates_user():
    repo = FakeUserRepo()
    status = signup(repo, "user@example.com")
    assert status == 201
    assert repo.find("user@example.com") is not None


def test_signup_rejects_invalid_email():
    repo = FakeUserRepo()
    assert signup(repo, "not-an-email") == 400
    assert repo.count() == 0


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
Save with Ctrl+S. Then:
```bash
pytest                                  # 1 failed: assert 201 == 409  (red = bug reproduced)
git add test_signup.py
git commit -m "Add failing test for duplicate email signup"
```
Now the fix. In the Files panel open `signup.py` and add two lines inside `signup`, before
`repo.save(email)`, so the function reads:
```python
def signup(repo, email):
    """Create an account. Returns an HTTP-style status code:
    201 created, 400 invalid email, 409 email already in use."""
    if "@" not in email:
        return 400
    if repo.find(email) is not None:
        return 409
    repo.save(email)
    return 201
```
(The `FakeUserRepo` class above it stays as it is.) Save with Ctrl+S. Then:
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
