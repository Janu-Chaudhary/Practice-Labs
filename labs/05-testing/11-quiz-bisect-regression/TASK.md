# 05-testing / 11 - Which commit broke it? git bisect, then test + fix  (Quiz-style, hard)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add docstring to free_shipping
xxxxxxx Add VAT test
xxxxxxx Explain how to run tests in README
xxxxxxx Add VAT helper
xxxxxxx Tidy pricing code
xxxxxxx Move bulk discount numbers into constants
xxxxxxx Add free shipping rule
xxxxxxx Add README
xxxxxxx (tag: v1.0) Add pricing with bulk discount
$ pytest -q
4 passed
```

## Situation
Rule: an order of **10 or more** items gets 10% off. Release `v1.0` (the first commit, tagged) did this
right. A customer now reports that buying **exactly 10** items gives no discount. CI stayed green the
whole time, because no test checks 10 items (only 3 and 20).

You don't know which of the 8 later commits broke it. Reading every diff is slow. `git bisect` does a
binary search through history for you: you mark one commit **bad** and one **good**, and git checks out
the middle commit; with `git bisect run <command>` git runs the command on each step by itself
(exit code 0 = good, 1 = bad).

## Task
1. Write a regression test that checks 10 items get the discount (for example
   `assert bulk_discount(10) == 0.10`). Put it in a **new file** `test_regression.py` (an untracked
   file stays in place while bisect checks out old commits). Run `pytest` and see it fail.
2. Use `git bisect` with `git bisect run` and your test to find the **first bad commit**.
3. Write its hash (at least 7 characters) as line 1 of `answer.txt` (it is in `.gitignore`, don't commit it).
4. Stop bisecting: `git bisect reset` (puts you back on main).
5. Then the usual two commits on `main`:
   1. the regression test only (message contains `failing test`)
   2. the fix in `pricing.py` only (smallest change). `pytest` green.

## Stop
- Don't rewrite or revert the old commits; fix forward with a new commit.
- Exactly two new commits. Don't push. Leave no bisect session running.

## What will be checked
- answer.txt line 1 = the first bad commit; no bisect in progress
- 11 commits on main; the original 9 untouched
- HEAD~1: message has "failing test", only `test_*.py` files changed, pytest FAILS there
- HEAD: only pricing.py changed, all tests pass (>= 5), bulk_discount(9)=0.0, (10)=0.10, (20)=0.10
- no uncommitted changes to tracked files

Hints: `git bisect start`, `git bisect bad`, `git bisect good v1.0`, `git bisect run pytest -q test_regression.py`.
`git show <hash>` shows what that commit changed. Lost? `git bisect reset` then `cd .. && ./setup.sh`.
