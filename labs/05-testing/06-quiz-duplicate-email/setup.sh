#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > signup.py <<'EOF'
class FakeUserRepo:
    """Fake: a working but simplified in-memory stand-in for the users table."""

    def __init__(self):
        self._users = {}

    def save(self, email):
        self._users[email] = {"email": email}

    def find(self, email):
        return self._users.get(email)

    def count(self):
        return len(self._users)


def signup(repo, email):
    """Create an account. Returns an HTTP-style status code:
    201 created, 400 invalid email, 409 email already in use."""
    if "@" not in email:
        return 400
    repo.save(email)
    return 201
EOF
cat > test_signup.py <<'EOF'
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
EOF
git add . && git commit -q -m "Add signup with in-memory fake repo"
git rev-parse HEAD > .git/lab-base
banner "05-testing/06-quiz-duplicate-email"
