#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > tickets.py <<'EOF'
def ticket_price(age):
    """Cinema ticket price in dollars.

    age 0-4    -> 0  (free)
    age 5-17   -> 8  (child)
    age 18-64  -> 15 (adult)
    age 65-120 -> 10 (senior)
    age below 0 or above 120 -> ValueError
    """
    if age < 0 or age >= 120:
        raise ValueError("age must be between 0 and 120")
    if age < 5:
        return 0
    if age < 18:
        return 8
    if age <= 65:
        return 15
    return 10
EOF
cat > test_tickets.py <<'EOF'
from tickets import ticket_price


def test_adult():
    assert ticket_price(30) == 15


def test_child():
    assert ticket_price(10) == 8
EOF
git add . && git commit -q -m "Add ticket prices"
git rev-parse HEAD > .git/lab-base
banner "05-testing/12-quiz-parametrize-ticket-prices"
