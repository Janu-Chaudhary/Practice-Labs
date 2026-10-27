# 05-testing / 02 - Write boundary tests  (Drill)

## Situation
`age.py` has `is_adult(age)`. Rule: **18 or older** is an adult; a **negative** age is invalid and
raises `ValueError`. `test_age.py` only tests normal cases (30 and 5). Most real bugs live at the
edge of a condition, so the suite is weak.

## Task
Add three tests to `test_age.py` (open it in the Files panel, save with Ctrl+S):
1. **Boundary, below**: 17 is not an adult.
2. **Boundary, at**: exactly 18 is an adult.
3. **Invalid**: `is_adult(-1)` raises `ValueError`. Use `pytest.raises` (you need `import pytest` at the top).

Run `pytest -v` to see every test name and its result. All must pass.

## Stop
- Do not change `age.py` (it is correct). No commit needed.

## What will be checked
- age.py unchanged; at least 5 tests; all pass
- the checker plants small bugs in a copy of age.py (`>=` -> `>`, `18` -> `17`, removing the `raise`)
  and your tests must turn red for each one
- pytest.raises(ValueError ...) is used
