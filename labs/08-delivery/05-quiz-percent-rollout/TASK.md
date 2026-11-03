# 05 - Percentage rollout: sticky buckets, not random() (Quiz-style)

```
$ git log --oneline
5f0c3a1 (HEAD -> main) Add rollout tests
2b9d7e4 Add rollout helper

$ python3 -m pytest -q
F..F.F                                                     [100%]
3 failed, 3 passed          (run it again: the numbers can change. That's random() for you)
```

**Context:** `work/rollout.py` decides whether a feature flag is ON for a user when the flag is
rolled out to `percent` % of users (slide: `hash(user_id) % 100 < 10`, not `random() < 0.1`).
A teammate wrote it, and it has two bugs:
- `is_enabled` uses `random.random()`, so the same user flickers ON/off between page loads;
- `bucket` hashes only the user, so every flag at 10% would hit the **same** 10% of users.

**Task** (inside `work/`):
1. Fix `rollout.py` (in the Files panel) so that:
   - `bucket(flag, user)` = take `sha256` of the text `"<flag>:<user>"` (e.g. `"group_order:meena"`),
     read the **first 4 bytes** as a big-endian number, return it `% 100` (a number 0-99);
   - `is_enabled(flag, user, percent)` is `True` exactly when `bucket(flag, user) < percent`;
   - the module does not use `random` at all.
2. Run the tests until they all pass.
3. Commit with the message `Use sticky hash buckets for rollout`.

**Stop rules:** don't edit anything in `tests/` or `pytest.ini`. Exactly one new commit.

**Hints**
- `hashlib.sha256("group_order:meena".encode()).digest()` gives 32 bytes; `digest[:4]` are the
  first 4; `int.from_bytes(b, "big")` turns bytes into a number. An f-string builds the text:
  `f"{flag}:{user}"`.
- Run the tests: `python3 -m pytest -q` (or `pytest -q`). `-k sticky`-style filters and `-x`
  (stop at first failure) help while you work.
- Remove the `import random` line too.
- `git status` before committing: only `rollout.py` should be modified.

**What will be checked**
- all tests pass; `rollout.py` has no `random`
- `bucket` and `is_enabled` match the spec for thousands of (flag, user, percent) combinations
- `tests/` unchanged; main has 3 commits, the last is exactly `Use sticky hash buckets for rollout`; tree clean
