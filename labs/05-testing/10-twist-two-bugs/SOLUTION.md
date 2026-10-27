# Solution - 10-twist-two-bugs

```bash
pytest                                   # 3 passed - neither bug is tested
```
Pair 1 - add to `test_shop.py`:
```python
def test_order_of_exactly_50_ships_free():
    assert shipping_cost(50) == 0
```
```bash
pytest                                   # 1 failed (assert 5 == 0)
git add test_shop.py && git commit -m "Add failing test for free shipping at 50"
# shop.py: change   if total > 50:   to   if total >= 50:
pytest                                   # 4 passed
git add shop.py && git commit -m "Fix free shipping to start at 50"
```
Pair 2 - add to `test_shop.py`:
```python
def test_four_digit_postcode_is_valid():
    assert is_valid_postcode("3000") is True
```
```bash
pytest                                   # 1 failed
git add test_shop.py && git commit -m "Add failing test for 4-digit postcode"
# shop.py: change   len(code) == 5   to   len(code) == 4
pytest                                   # 5 passed
git add shop.py && git commit -m "Fix postcode length to 4 digits"
git log --oneline                        # 5 commits
cd .. && ./check.sh
```

Why: each pair is a small, reviewable story - "here is the bug, proven" then "here is the fix".
If one fix is later reverted, its test goes red again: that's what a regression test is for.

Common wrong attempts:
- Writing both tests in commit 1 -> commit 2 (only shipping fixed) is still red -> "commit 2: pytest PASSES" fails.
- Fixing both bugs in commit 2 -> commit 3's new test passes immediately: it never failed, so it proves nothing.
- `git commit -am` while shop.py and test_shop.py are both edited -> one commit holds both files.
- Made a commit too many? `git reset --soft HEAD~1`, fix up, commit again.
