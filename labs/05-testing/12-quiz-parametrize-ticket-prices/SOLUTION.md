# Solution - 12-quiz-parametrize-ticket-prices

In the Files panel open `test_tickets.py` and make it read:
```python
import pytest
from tickets import ticket_price


def test_adult():
    assert ticket_price(30) == 15


def test_child():
    assert ticket_price(10) == 8


@pytest.mark.parametrize("age, expected", [
    (0, 0), (4, 0),        # free: lowest valid age, last free age
    (5, 8), (17, 8),       # child: first and last
    (18, 15), (64, 15),    # adult: first and last
    (65, 10), (120, 10),   # senior: first and the highest valid age
])
def test_price_at_every_edge(age, expected):
    assert ticket_price(age) == expected


@pytest.mark.parametrize("age", [-1, 121])
def test_invalid_age_raises(age):
    with pytest.raises(ValueError):
        ticket_price(age)
```
Save with Ctrl+S. Then:
```bash
pytest -v          # 12 lines; FAILED: [65-10] (got 15), [120-10] (ValueError raised)
git add test_tickets.py
git commit -m "Add failing test table for ticket price boundaries"
```
Fix `tickets.py`: in the Files panel open it and change `age >= 120` -> `age > 120`, and
`age <= 65` -> `age < 65`, so it reads:
```python
def ticket_price(age):
    """Cinema ticket price in dollars.

    age 0-4    -> 0  (free)
    age 5-17   -> 8  (child)
    age 18-64  -> 15 (adult)
    age 65-120 -> 10 (senior)
    age below 0 or above 120 -> ValueError
    """
    if age < 0 or age > 120:
        raise ValueError("age must be between 0 and 120")
    if age < 5:
        return 0
    if age < 18:
        return 8
    if age < 65:
        return 15
    return 10
```
Save with Ctrl+S. Then:
```bash
pytest -v          # 12 passed
git add tickets.py
git commit -m "Fix ticket price edges at 65 and 120"
cd .. && ./check.sh
```

Why:
- The `"age, expected"` string names the parameters; each tuple is one run. pytest shows them as
  `test_price_at_every_edge[65-10]`, so you see exactly which edge is wrong.
- For each edge test the **last value inside** and the **first value outside** (64 and 65). Testing
  only one side lets a `<` vs `<=` mistake hide (that is what the checker's mutants try).
- Invalid input: `with pytest.raises(ValueError):` passes only if the code inside raises that error.
  Without it, a raised error just makes the test crash (red), and "no error" would pass silently.

Common wrong attempts:
- `@pytest.mark.parametrize("age", "expected", [...])` -> error: the names are ONE comma-separated string.
- Forgetting `import pytest` -> `NameError: name 'pytest' is not defined` at collection (exit code 2).
- Only testing 65 (not 64) -> the mutant `age < 64` survives. Only 120 (not 121) -> `age > 121` survives.
- Putting `ticket_price(-1)` outside the `with` block -> the error escapes, test is red.
- Fixing tickets.py before the first commit, then `git add .` -> the fix lands in the test commit.
