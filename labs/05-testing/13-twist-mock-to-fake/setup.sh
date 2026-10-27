#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > orders.py <<'EOF'
class PostgresOrderRepo:
    """The real repository. Needs a running Postgres server, so tests must NOT use it.

    Every order repository has two methods:
        save(order)  store one order (a dict like {"item": "pen", "qty": 2})
        all()        return a list of every stored order
    """

    def __init__(self, url):
        raise RuntimeError("needs a real database at " + url)


def place_order(repo, item, qty):
    """Place an order. Returns an HTTP-style status code:
    201 = created and stored
    400 = qty must be from 1 to 10; a rejected order must NOT be stored
    """
    order = {"item": item, "qty": qty}
    repo.save(order)
    if qty < 1 or qty > 10:
        return 400
    return 201
EOF
cat > test_orders.py <<'EOF'
from unittest.mock import Mock

from orders import place_order


def test_place_order():
    repo = Mock()
    place_order(repo, "pen", 2)
    repo.save.assert_called()


def test_too_many_items_rejected():
    repo = Mock()
    assert place_order(repo, "pen", 11) == 400
EOF
git add . && git commit -q -m "Add order placement with tests (100% coverage)"
git rev-parse HEAD > .git/lab-base
banner "05-testing/13-twist-mock-to-fake"
