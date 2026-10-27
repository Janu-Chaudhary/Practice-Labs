# Solution - 11-quiz-bisect-regression

In the Files panel click **+ New file**, type `test_regression.py`, and make it read:
```python
from pricing import bulk_discount


def test_exactly_ten_items_get_discount():
    assert bulk_discount(10) == 0.10
```
Save with Ctrl+S. Then in the terminal, inside `work/`:
```bash
pytest -q                           # 1 failed (assert 0.0 == 0.1), 4 passed: bug reproduced
git bisect start                    # begin a bisect session
git bisect bad                      # the current commit (HEAD) is bad
git bisect good v1.0                # the tagged release was good -> git checks out the middle commit
git bisect run pytest -q test_regression.py
                                    # git runs the test on each middle commit by itself
                                    # last lines:  <hash> is the first bad commit ... Tidy pricing code
git bisect log | tail -1            # "# first bad commit: [<hash>] Tidy pricing code" (if it scrolled away)
git show <hash>                     # see the culprit: "if qty >= BULK_MIN" became "if qty > BULK_MIN"
git bisect reset                    # end bisect, back on main at the newest commit
git status                          # On branch main; test_regression.py untracked
```
In the Files panel click **+ New file**, type `answer.txt`, and paste the hash bisect printed
(7+ characters) as line 1, e.g.:
```
e660570
```
Save with Ctrl+S. (`answer.txt` is in `.gitignore`, so git ignores it.)
Commit 1, the failing test:
```bash
git add test_regression.py
git commit -m "Add failing test for exactly 10 items bulk discount"
```
Commit 2, the fix: in the Files panel open `pricing.py` and change `if qty > BULK_MIN:` to
`if qty >= BULK_MIN:`, so `bulk_discount` reads:
```python
def bulk_discount(qty):
    """Orders of 10 or more items get 10% off. Returns the discount rate."""
    rate = 0.0
    if qty >= BULK_MIN:
        rate = BULK_RATE
    return rate
```
Save with Ctrl+S. Then:
```bash
pytest -q                           # 5 passed
git add pricing.py
git commit -m "Fix bulk discount for exactly 10 items"
git log --oneline | head -3
cd .. && ./check.sh
```

Why each piece:
- `git bisect run` uses the **exit code**: 0 = good, 1-127 = bad (except 125 = "can't test, skip").
  pytest gives 0 when green and 1 when a test fails, so it plugs straight in.
- The test is in a new, **untracked** file. Bisect checks out old commits; untracked files stay put,
  so the same test runs on every commit. 9 commits -> about 3 test runs instead of 8.
- The old tests (3 and 20 items) never noticed: 3 and 20 are not the boundary. The edge is 10.

Common wrong attempts:
- Adding the test to `test_pricing.py` (tracked) before bisecting -> `git bisect` / checkout may refuse
  ("Your local changes would be overwritten") because that file differs between commits.
- `git bisect run pytest` (whole suite): works here, but on a real project other unrelated failures
  would mark commits bad. Run only the regression test.
- Forgetting `git bisect reset` -> you are left on a detached HEAD in the middle of history; your next
  commits would not be on main. Check fails "bisect is finished".
- Writing the "found" hash from `git log` instead of the bisect output -> wrong commit (e.g. the
  "constants" commit, which was still correct: `>= BULK_MIN`).
- `git revert <bad>` -> also undoes the tidy-up and is not the test-then-fix pair. Fix forward.
- `git add .` for commit 1 -> fine only if pricing.py is still unchanged; answer.txt is ignored.
