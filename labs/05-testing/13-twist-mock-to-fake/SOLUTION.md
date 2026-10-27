# Solution - 13-twist-mock-to-fake

Replace `test_orders.py` with (`code test_orders.py`):
```python
from orders import place_order


class FakeOrderRepo:
    """Fake: a working in-memory stand-in for PostgresOrderRepo."""

    def __init__(self):
        self.orders = []

    def save(self, order):
        self.orders.append(dict(order))

    def all(self):
        return list(self.orders)


def test_valid_order_is_created_and_stored():
    repo = FakeOrderRepo()                       # Arrange
    status = place_order(repo, "pen", 2)         # Act
    assert status == 201                         # Assert: the response...
    assert repo.all() == [{"item": "pen", "qty": 2}]   # ...and exactly what was stored


def test_edges_1_and_10_are_accepted():
    repo = FakeOrderRepo()
    assert place_order(repo, "pen", 1) == 201
    assert place_order(repo, "ink", 10) == 201
    assert repo.all() == [{"item": "pen", "qty": 1}, {"item": "ink", "qty": 10}]


def test_qty_0_rejected_and_not_stored():
    repo = FakeOrderRepo()
    assert place_order(repo, "pen", 0) == 400
    assert repo.all() == []


def test_qty_11_rejected_and_not_stored():
    repo = FakeOrderRepo()
    assert place_order(repo, "pen", 11) == 400
    assert repo.all() == []
```
```bash
pytest -q        # 2 failed: assert [{'item': 'pen', 'qty': 0}] == []  -> rejected orders ARE stored
git add test_orders.py
git commit -m "Replace mock with fake repo; add failing test for stored rejected orders"
```
Fix `orders.py`: validate **before** saving. `place_order` becomes:
```python
    if qty < 1 or qty > 10:
        return 400
    order = {"item": item, "qty": qty}
    repo.save(order)
    return 201
```
```bash
pytest -q        # 4 passed
git add orders.py
git commit -m "Validate qty before saving the order"
cd .. && ./check.sh
```

Why:
- **Mock** = records calls. `assert_called()` passes as long as `save` ran once, whatever was saved,
  and even when the order should have been refused. 100% coverage only means every line **ran**.
- **Fake** = a real (simplified) implementation. Because it really stores, the test can check the
  outcome: the status code and the stored data. That is "behaviour-focused" (lecture slide).
- **Stub** would just return canned values; it can't tell you what was stored either.
- The edge cases 1 and 10 kill the off-by-one versions (`qty < 0`, `qty >= 10`).

Common wrong attempts:
- Keeping `repo.save.assert_called()` and adding `assert status == 400` -> still passes on the bug:
  the status IS 400, the problem is the stored row. Only "nothing stored" catches it.
- `assert len(repo.all()) == 1` for the valid case -> misses "stores the wrong qty / item". Compare the dict.
- Fake `save` that does nothing (`pass`) -> that's a stub/mock again; `all()` is always empty.
- Moving the `if` but keeping `repo.save(order)` above it too -> saves twice / still stores rejects.
- Committing the fix together with the tests -> HEAD~1 is green, check "pytest FAILS at HEAD~1" fails.
