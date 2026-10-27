#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > age.py <<'EOF'
ADULT_AGE = 18


def is_adult(age):
    """Rule: 18 or older is an adult. A negative age is invalid."""
    if age < 0:
        raise ValueError("age cannot be negative")
    return age >= ADULT_AGE
EOF
cat > test_age.py <<'EOF'
from age import is_adult


def test_thirty_year_old_is_adult():
    # Arrange
    age = 30
    # Act
    result = is_adult(age)
    # Assert
    assert result is True


def test_five_year_old_is_not_adult():
    assert is_adult(5) is False
EOF
git add . && git commit -q -m "Add is_adult with normal-case tests"
banner "05-testing/02-boundary-tests"
