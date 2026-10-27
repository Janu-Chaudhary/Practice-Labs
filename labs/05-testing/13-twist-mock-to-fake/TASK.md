# 05-testing / 13 - 100% coverage, zero confidence: replace the mock with a fake  (Twist, hard)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add order placement with tests (100% coverage)
$ pytest -q
2 passed
```

## Situation
`orders.py` has `place_order(repo, item, qty)`. Rule: qty must be **1 to 10**. A valid order returns
`201` and is stored; an invalid one returns `400` and must **not** be stored. The real repo is
`PostgresOrderRepo` (needs a database server, so tests can't use it).

The tests use `unittest.mock.Mock()` as the repo. Coverage says 100%: every line of `place_order` ran.
Yet in production, rejected orders (qty 11) show up in the database. The tests never noticed because:
- `repo.save.assert_called()` proves `save` was **called**, not **what** was stored, and not the status.
- a Mock stores nothing, so no test can ask "what is in the database now?"

(Quiz 2 Q2 is this exact situation: a mocked db and `db.save.assert_called()` with 100% coverage.)

## Task
Exactly two new commits on `main`:
1. Rewrite `test_orders.py`:
   - remove `Mock` completely
   - write your own **fake** repo class in the test file: a working, in-memory version with
     `save(order)` (append to a list) and `all()` (return the list)
   - real assertions (Arrange-Act-Assert), at least these cases:
     a valid order -> `201` and `repo.all()` is exactly `[{"item": ..., "qty": ...}]`;
     qty `0` and qty `11` -> `400` and `repo.all() == []`; the edges qty `1` and `10` -> `201`, stored.
   `pytest` must be red (the bug is caught). Commit only the test file, message contains `failing test`.
2. Fix `orders.py` (smallest change). `pytest` green. Commit only `orders.py`.

## Stop
- Don't use `Mock`, `MagicMock` or `patch`. Don't touch `PostgresOrderRepo`. No extra commits, don't push.

## What will be checked
- 3 commits; HEAD~1 = test_orders.py only, "failing test" in the message, pytest FAILS there
- no `Mock` in test_orders.py; it defines a class with `def save` and `def all`
- HEAD = orders.py only; at least 4 tests pass; they also pass on a known-correct orders.py
- your tests FAIL on each of 8 broken versions of place_order: stores rejected orders, never stores,
  stores twice, stores the wrong qty, stores the wrong item, accepts qty 0, rejects qty 10, returns 200
- the fixed code behaves correctly
