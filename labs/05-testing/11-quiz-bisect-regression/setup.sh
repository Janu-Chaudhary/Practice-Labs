#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\nanswer.txt\n' > .gitignore
cat > pricing.py <<'EOF'
def bulk_discount(qty):
    """Orders of 10 or more items get 10% off. Returns the discount rate."""
    if qty >= 10:
        return 0.10
    return 0.0


def line_total(price, qty):
    return round(price * qty * (1 - bulk_discount(qty)), 2)
EOF
cat > test_pricing.py <<'EOF'
from pricing import line_total


def test_small_order_pays_full_price():
    assert line_total(2.0, 3) == 6.0


def test_big_order_gets_discount():
    assert line_total(2.0, 20) == 36.0
EOF
git add . && git commit -q -m "Add pricing with bulk discount"
git tag v1.0
commit_file README.md "# Shop pricing" "Add README"
cat >> pricing.py <<'EOF'


def free_shipping(total):
    return total >= 50
EOF
cat >> test_pricing.py <<'EOF'


def test_free_shipping_from_50():
    from pricing import free_shipping
    assert free_shipping(50) is True
    assert free_shipping(49.99) is False
EOF
git add . && git commit -q -m "Add free shipping rule"
python3 - <<'EOF'
p = open("pricing.py").read()
p = p.replace('def bulk_discount', 'BULK_MIN = 10\nBULK_RATE = 0.10\n\n\ndef bulk_discount')
p = p.replace("if qty >= 10:\n        return 0.10", "if qty >= BULK_MIN:\n        return BULK_RATE")
open("pricing.py", "w").write(p)
EOF
git add . && git commit -q -m "Move bulk discount numbers into constants"
python3 - <<'EOF'
p = open("pricing.py").read()
p = p.replace("if qty >= BULK_MIN:\n        return BULK_RATE\n    return 0.0",
              "rate = 0.0\n    if qty > BULK_MIN:\n        rate = BULK_RATE\n    return rate")
open("pricing.py", "w").write(p)
EOF
git add . && git commit -q -m "Tidy pricing code"
cat >> pricing.py <<'EOF'


def with_vat(amount, rate=0.15):
    return round(amount * (1 + rate), 2)
EOF
git add . && git commit -q -m "Add VAT helper"
printf '# Shop pricing\n\nRun the tests with: pytest\n' > README.md
git add . && git commit -q -m "Explain how to run tests in README"
cat >> test_pricing.py <<'EOF'


def test_vat_15_percent():
    from pricing import with_vat
    assert with_vat(100) == 115.0
EOF
git add . && git commit -q -m "Add VAT test"
sed -i 's/^def free_shipping(total):/def free_shipping(total):\n    """Orders of 50 or more ship free."""/' pricing.py
git add . && git commit -q -m "Add docstring to free_shipping"
git rev-parse HEAD > .git/lab-base
banner "05-testing/11-quiz-bisect-regression"
