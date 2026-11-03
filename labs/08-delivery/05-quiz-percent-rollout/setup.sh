#!/usr/bin/env bash
# Quiz-style: fix a percentage rollout so it is sticky (sha256 bucket, not random) and salted with the
# flag name, make the tests pass, commit with an exact message.
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
printf '[pytest]\npythonpath = .\n' > pytest.ini
cat > rollout.py <<'PY'
"""Percentage rollout for feature flags (the Python twin of the lecture's rollout.js)."""
import hashlib
import random


def bucket(flag, user):
    """Turn (flag, user) into a number from 0 to 99. Same input, same number, every time."""
    digest = hashlib.sha256(user.encode()).digest()
    return int.from_bytes(digest[:4], "big") % 100


def is_enabled(flag, user, percent):
    """True if `flag` is ON for `user` while the flag is rolled out to `percent` % of users."""
    return random.random() < percent / 100
PY
git add .gitignore pytest.ini rollout.py
git commit -q -m "Add rollout helper"
mkdir tests
cat > tests/test_rollout.py <<'PY'
from rollout import bucket, is_enabled

USERS = [f"user_{i}" for i in range(1, 10001)]


def test_same_user_always_gets_the_same_answer():
    # no flicker: the button must not appear and disappear between page loads
    for user in ["asha", "ravi", "meena", "kabir", "zoya"]:
        answers = {is_enabled("group_order", user, 50) for _ in range(30)}
        assert len(answers) == 1


def test_zero_is_nobody_and_hundred_is_everyone():
    assert not any(is_enabled("group_order", u, 0) for u in USERS[:500])
    assert all(is_enabled("group_order", u, 100) for u in USERS[:500])


def test_ten_percent_is_about_ten_percent():
    on = sum(is_enabled("group_order", u, 10) for u in USERS)
    assert 900 <= on <= 1100


def test_raising_the_percentage_never_switches_anyone_off():
    for u in USERS[:2000]:
        if is_enabled("group_order", u, 10):
            assert is_enabled("group_order", u, 50)


def test_two_flags_pick_different_users():
    # with hash(user) only, the SAME 10% would test every feature
    both = sum(is_enabled("group_order", u, 10) and is_enabled("new_menu", u, 10) for u in USERS)
    assert both < 300


def test_bucket_matches_the_spec():
    # sha256("group_order:meena") -> first 4 bytes big-endian -> % 100
    assert bucket("group_order", "meena") == 5
    assert bucket("group_order", "asha") == 67
PY
git add tests/test_rollout.py
git commit -q -m "Add rollout tests"
git rev-parse HEAD > .git/lab-tests-commit
banner "05-quiz-percent-rollout (Quiz-style): make is_enabled sticky and fair, then commit"
