#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > shop.py <<'EOF'
def shipping_cost(total):
    """Orders of 50 or more ship free. Smaller orders pay 5."""
    if total > 50:
        return 0
    return 5


def is_valid_postcode(code):
    """A postcode is exactly 4 digits, e.g. "3000"."""
    return len(code) == 5 and code.isdigit()
EOF
cat > test_shop.py <<'EOF'
from shop import shipping_cost, is_valid_postcode


def test_small_order_pays_shipping():
    assert shipping_cost(10) == 5


def test_big_order_ships_free():
    assert shipping_cost(120) == 0


def test_postcode_with_letters_is_invalid():
    assert is_valid_postcode("30a0") is False
EOF
git add . && git commit -q -m "Add shipping and postcode rules"
git rev-parse HEAD > .git/lab-base
banner "05-testing/10-twist-two-bugs"
