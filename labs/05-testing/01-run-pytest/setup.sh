#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > cart.py <<'EOF'
TAX_RATE = 0.15


def subtotal(prices):
    return sum(prices)


def total_with_tax(prices):
    """Subtotal plus 15% tax, rounded to cents."""
    return round(subtotal(prices) * TAX_RATE, 2)


def item_count(prices):
    return len(prices)


def most_expensive(prices):
    return max(prices) if prices else None
EOF
cat > test_cart.py <<'EOF'
from cart import subtotal, total_with_tax, item_count, most_expensive


def test_subtotal_adds_prices():
    assert subtotal([10, 20, 5]) == 35


def test_subtotal_of_empty_cart_is_zero():
    assert subtotal([]) == 0


def test_item_count():
    assert item_count([1, 2, 3]) == 3


def test_most_expensive():
    assert most_expensive([4, 99, 12]) == 99


def test_most_expensive_of_empty_cart_is_none():
    assert most_expensive([]) is None


def test_total_with_tax_adds_15_percent():
    assert total_with_tax([100]) == 115.0
EOF
git add . && git commit -q -m "Add cart and tests"
banner "05-testing/01-run-pytest"
