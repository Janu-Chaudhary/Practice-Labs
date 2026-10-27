# Solution - 03-test-that-asserts-nothing

In the Files panel open `test_discount.py` and make it read:

```python
from discount import apply_discount


def test_ten_percent_off_200():
    # Arrange
    price, percent = 200, 10
    # Act
    result = apply_discount(price, percent)
    # Assert
    assert result == 180


def test_zero_percent_changes_nothing():
    assert apply_discount(80, 0) == 80
```
Save with Ctrl+S. Then:

```bash
pytest                       # 1 failed, 1 passed: assert 190 == 180  -> red, as wanted
git status                   # see what changed: only test_discount.py
git add test_discount.py     # stage ONLY the test file
git commit -m "Add failing test for 10% discount"
git log --oneline            # 2 commits
cd .. && ./check.sh
```

Why: a test without `assert` only proves "the code ran without crashing". Coverage tools would
still count those lines as covered - coverage measures execution, not checking.

Common wrong attempts:
- `assert result` -> 190 is truthy, still passes. Assert the exact value.
- `assert result == 190` -> that locks in the bug; the last check (fixed code must pass) catches it.
- `git add .` or `git commit -am` -> fine here only if nothing else changed; get into the habit of adding the one file.
- Also fixing discount.py in the same commit -> the test never fails in history; fails "discount.py unchanged".
