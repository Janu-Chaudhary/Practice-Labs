# Solution - 05-quiz-percent-rollout

```bash
cd work
python3 -m pytest -q          # 3 failed: same_user..., raising_the_percentage..., bucket_matches_the_spec
                              # (the count can change between runs: random() makes the result random too)
```

In the Files panel open `rollout.py`, make it exactly this, save with **Ctrl+S**:
```python
"""Percentage rollout for feature flags (the Python twin of the lecture's rollout.js)."""
import hashlib


def bucket(flag, user):
    """Turn (flag, user) into a number from 0 to 99. Same input, same number, every time."""
    digest = hashlib.sha256(f"{flag}:{user}".encode()).digest()
    return int.from_bytes(digest[:4], "big") % 100


def is_enabled(flag, user, percent):
    """True if `flag` is ON for `user` while the flag is rolled out to `percent` % of users."""
    return bucket(flag, user) < percent
```

```bash
python3 -m pytest -q          # 6 passed
git status                    # modified: rollout.py   (only that)
git add rollout.py
git commit -m "Use sticky hash buckets for rollout"
git log --oneline             # 3 commits
```

Why:
- **Sticky**: sha256 of the same text is always the same, so a user's bucket never changes. With
  `random()` the "group order" button would appear and disappear on every page load.
- **Fair share**: sha256 spreads users evenly over 0-99, so `bucket < 10` is about 10% (10,000 users:
  1,005 ON, like the demo).
- **Monotonic**: going 10 -> 50 -> 100 only moves the line. Nobody who had the feature loses it.
  0 = nobody (kill switch), 100 = everyone.
- **Flag name in the hash**: each flag gets its own independent 10%. With `hash(user)` only, the
  two flags overlap 100% (978 of 978); with `"flag:user"` about 1% of users are in both (99).
- `% 100`: the remainder after dividing by 100 is always 0-99.
- `digest[:4]` + `"big"`: the same 4 bytes, read the same way, as the JavaScript demo's
  `readUInt32BE(0)`, so both give meena = 5, asha = 67.

## Common wrong attempts
- `hashlib.sha256(flag + user)` -> TypeError: sha256 needs **bytes**, call `.encode()`. And no
  `:` gives different buckets from the spec ("group_ordermeena").
- `hash(f"{flag}:{user}") % 100` (Python's built-in `hash`) -> different on every Python run
  (string hashing is randomised per process), so it is NOT sticky across servers or restarts.
- `int(digest.hex(), 16) % 100` -> uses all 32 bytes, a different number from the spec.
- `int.from_bytes(digest[:4], "little")` -> different byte order, different buckets.
- `bucket(...) <= percent` -> at 0% bucket-0 users still get it: the kill switch leaks.
- `return bucket(flag, user) < percent / 100` -> compares 0-99 with 0.1: nobody is ever ON.
- Keeping `random.seed(user)` tricks -> still `random`; the check rejects it.
- Editing the tests to make them pass -> the check compares `tests/` with the original.
- `git commit -am "..."` is fine here (rollout.py is tracked). `git add .` is also fine because
  `.gitignore` hides `__pycache__/`.
