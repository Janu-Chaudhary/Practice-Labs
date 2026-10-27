# 05-testing / 06 - Duplicate email signup: failing test, then fix  (Quiz-style)

## Situation
Bug report: signing up twice with the same email returns **201 Created** both times. It should
return **409 Conflict** the second time, and the user must be stored only once.

`signup.py` has `signup(repo, email)` and `FakeUserRepo`, an in-memory **fake** of the users table
(a working but simplified implementation; no real database needed). `test_signup.py` has 2 tests.

## Task
Exactly two new commits on `main`:
1. A test that reproduces the bug using `FakeUserRepo`: sign up the same email twice, assert the
   second call returns `409` (and, ideally, that `repo.count()` is 1). Commit message contains `failing test`.
   Only the test file goes in this commit.
2. The fix in `signup.py` (smallest change that turns pytest green).

Run `pytest` before each commit: red before commit 1, green before commit 2.

## Stop
- Don't use `unittest.mock.Mock` here: a mock only proves `save` was called, not that signup behaves.
- No extra commits. Don't push.

## What will be checked
- 3 commits on main; HEAD~1 = test only, message has "failing test", contains 409, uses FakeUserRepo
- pytest fails at HEAD~1 and passes at HEAD (>= 3 tests)
- HEAD changes only signup.py and the same email twice gives 201 then 409
