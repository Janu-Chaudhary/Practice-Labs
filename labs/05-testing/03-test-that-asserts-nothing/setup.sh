#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > discount.py <<'EOF'
def apply_discount(price, percent):
    """Return the price after taking `percent` percent off. 200 with 10% off -> 180."""
    return price - percent
EOF
cat > test_discount.py <<'EOF'
from discount import apply_discount


def test_ten_percent_off_200():
    result = apply_discount(200, 10)
    print("result is", result)


def test_zero_percent_changes_nothing():
    assert apply_discount(80, 0) == 80
EOF
git add . && git commit -q -m "Add discount with tests"
banner "05-testing/03-test-that-asserts-nothing"
