#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > validate.py <<'EOF'
def is_valid_length(password):
    """A password needs at least 8 characters."""
    return len(password) > 8
EOF
cat > test_validate.py <<'EOF'
from validate import is_valid_length


def test_rejects_short_password():
    assert is_valid_length("abc") is False


def test_accepts_long_password():
    assert is_valid_length("correcthorsebattery") is True
EOF
git add . && git commit -q -m "Add password length check"
git rev-parse HEAD > .git/lab-base
banner "05-testing/05-quiz-password-length  (quiz 2 Q16)"
