# 05-testing / 03 - A test that asserts nothing  (Drill)

## Situation
`pytest` is all green: 2 passed. But `apply_discount(200, 10)` should give **180** and the code
returns 190. `test_ten_percent_off_200` calls the function and prints the result, but it never
**asserts** anything. A test with no assertion passes whenever the code does not crash.

## Task
1. Run `pytest` and `pytest -s` (`-s` shows print output). Notice it is green and prints 190.
2. Make `test_ten_percent_off_200` a real test: assert the expected value (Arrange-Act-Assert).
3. Run `pytest` again: that test must now **fail** (red). That is good: it caught the bug.
4. Commit **only** the test file, with a message that contains `failing test`.

## Stop
- Do NOT fix `discount.py` in this lab. (In the full workflow the fix is the next, separate commit.)
- Exactly one new commit.

## What will be checked
- 2 commits on main; the new one's message contains "failing test" and changes only test_discount.py
- discount.py unchanged
- at HEAD, test_ten_percent_off_200 fails and the other test passes
- your assert passes once discount.py is correct (so you asserted the right number)
