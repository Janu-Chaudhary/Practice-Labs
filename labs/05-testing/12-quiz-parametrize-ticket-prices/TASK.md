# 05-testing / 12 - A boundary table with parametrize  (Quiz-style, hard)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add ticket prices
$ pytest -q
2 passed
```

## Situation
`tickets.py` has `ticket_price(age)`:

| age        | price |
|------------|-------|
| 0 - 4      | 0 (free) |
| 5 - 17     | 8 (child) |
| 18 - 64    | 15 (adult) |
| 65 - 120   | 10 (senior) |
| below 0 or above 120 | `ValueError` |

The tests only try 30 and 10, so they are green. Customers say a 65-year-old pays the adult price and a
120-year-old gets an error. There may be more off-by-one bugs: every edge has **two sides**.

Writing one test function per age would be 12+ copies of the same code. `@pytest.mark.parametrize`
runs ONE test function once per row of a table, and pytest reports each row as its own test:

```python
@pytest.mark.parametrize("age, expected", [(4, 0), (5, 8)])
def test_price(age, expected):
    assert ticket_price(age) == expected
```

## Task
Exactly two new commits on `main`:
1. In `test_tickets.py` (needs `import pytest`):
   - one parametrized test for the **valid** ages: both sides of every edge (0, 4, 5, 17, 18, 64, 65, 120)
   - one parametrized test for the **invalid** ages (-1 and 121) using `pytest.raises(ValueError)`
   Run `pytest -v`: you see one line per row; some rows are red. Commit only the test file, message
   contains `failing test`.
2. Fix `tickets.py` (smallest change) so every row is green. Commit only `tickets.py`.

## Stop
- Don't delete the 2 existing tests. Don't change the price table. No extra commits, don't push.

## What will be checked
- 3 commits; HEAD~1 = test file only, message has "failing test", pytest FAILS there
- the tests use `@pytest.mark.parametrize` and `pytest.raises(ValueError`
- HEAD = tickets.py only; at least 12 test cases pass
- your tests pass on a correct tickets.py, and FAIL on each of 11 planted bugs
  (each `<` / `>` moved one step either way at every edge, and the `raise` removed)
- the fixed code gives the right price at every edge and raises for -1 and 121
