# Solution - 02-boundary-tests

In the Files panel open `test_age.py`. Add `import pytest` at the top and the three tests at the
end, so it reads:

```python
import pytest
from age import is_adult


def test_thirty_year_old_is_adult():
    # Arrange
    age = 30
    # Act
    result = is_adult(age)
    # Assert
    assert result is True


def test_five_year_old_is_not_adult():
    assert is_adult(5) is False


def test_seventeen_is_not_adult():      # boundary, one below
    assert is_adult(17) is False

def test_exactly_eighteen_is_adult():   # boundary, at the limit
    assert is_adult(18) is True

def test_negative_age_is_rejected():    # invalid input
    with pytest.raises(ValueError):
        is_adult(-1)
```
Save with Ctrl+S. Then:

```bash
pytest -v          # -v = one line per test, with PASSED/FAILED
cd .. && ./check.sh
```

Why each test:
- 18 kills the `>=` -> `>` bug (with `>`, 18 would say False).
- 17 kills the "limit is off by one" bug (with `>= 17`, 17 would say True).
- `pytest.raises(ValueError)` passes only if the code inside the `with` block raises that error.
  If no error is raised, the test fails with `DID NOT RAISE`.

Common wrong attempts:
- `assert is_adult(-1) == ValueError` -> the call raises before the compare, test errors out. Use `pytest.raises`.
- Forgetting `import pytest` -> `NameError: name 'pytest' is not defined`.
- Testing 20 and 50 -> these pass, but no boundary is tested; the mutant checks stay red.
- Two functions with the same name -> Python keeps only the last one; the first test silently disappears.
