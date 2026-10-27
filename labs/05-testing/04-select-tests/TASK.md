# 05-testing / 04 - Run only some tests  (Drill)

## Situation
On a big project the full suite is slow. You want to rerun just the tests you are working on.
`test_users.py` has 6 tests. (`conftest.py` only records which tests ran, for the checker. Ignore it.)

## Task
Inside `work/`, do four separate pytest runs:
1. The whole suite, verbose (one line per test).
2. Only the tests with `email` in their name (use `-k`).
3. Only `test_password_too_short` (use the `file::test` form).
4. Only tests with `password` in the name but **not** `short` (one `-k` expression).

Look at the last line of each run: how many passed, how many were "deselected"?

## Stop
- Don't edit any file.

## What will be checked
- each of the 4 runs happened and ran exactly the expected tests (extra runs are fine)
