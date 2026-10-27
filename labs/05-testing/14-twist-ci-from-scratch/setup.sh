#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n.ruff_cache/\n' > .gitignore
cat > temps.py <<'EOF'
import os


def c_to_f(c):
    return c * 9 / 5 + 32


def is_freezing(c):
    return c <= 0


def average(temps):
    total = sum(temps)
    return sum(temps) / len(temps)
EOF
cat > test_temps.py <<'EOF'
from temps import average, c_to_f, is_freezing


def test_boiling_point():
    assert c_to_f(100) == 212


def test_zero_is_freezing():
    assert is_freezing(0) is True
    assert is_freezing(0.1) is False


def test_average():
    assert average([10, 20, 30]) == 20
EOF
printf 'pytest\n' > requirements.txt
git add . && git commit -q -m "Add temperature helpers"
git rev-parse HEAD > .git/lab-base
banner "05-testing/14-twist-ci-from-scratch"
