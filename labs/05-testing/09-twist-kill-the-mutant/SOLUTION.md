# Solution - 09-twist-kill-the-mutant

```bash
python3 mutants.py      # all 3 SURVIVED: "abc" (3) and a 19-char password give the same answer for all of them
```
Add to `test_validate.py`:
```python
def test_accepts_exactly_eight_characters():   # kills  > 8  and  >= 9  (8 chars would be rejected)
    assert is_valid_length("abcdefgh") is True

def test_rejects_seven_characters():           # kills  >= 7  (7 chars would be accepted)
    assert is_valid_length("abcdefg") is False
```
```bash
pytest                  # 4 passed on the real code
python3 mutants.py      # All mutants killed.
git add test_validate.py
git commit -m "Add boundary tests for 7 and 8 characters"
cd .. && ./check.sh
```

Why: a boundary rule `>= 8` has two edges: the last bad value (7) and the first good value (8).
Test both. Values far from the edge (3, 19) can't tell `>=` from `>`.

Common wrong attempts:
- Only adding the 8-char test -> the `>= 7` mutant survives.
- Testing 9 chars -> still passes under `> 8`, mutant survives.
- Editing validate.py to make mutants.py happy -> fails "changed only test_validate.py".
