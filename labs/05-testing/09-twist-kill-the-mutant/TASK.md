# 05-testing / 09 - Kill the surviving mutants  (Twist)

## Situation
`validate.py` is **correct** (`len(password) >= 8`) and pytest is green. But is the test suite
strong? **Mutation testing** answers that: a tool makes a tiny change to the code (a "mutant"),
then reruns your tests. If the tests still pass, the mutant **survived**: your suite can't tell the
broken code from the right code. Coverage would say 100% here; mutation testing says "weak".

Run it: `python3 mutants.py`

## Task
1. Run `python3 mutants.py` and read which mutants survive.
2. Add the **missing boundary tests** to `test_validate.py` so every mutant is killed.
   Think: which password length makes `>= 8` and `> 8` give different answers? And `>= 8` vs `>= 7`?
3. `pytest` must stay green on the real code. `python3 mutants.py` must print "All mutants killed."
4. Commit only `test_validate.py` (one commit, any message).

## Stop
- Don't change `validate.py` or `mutants.py`. One new commit.

## What will be checked
- exactly one new commit, changing only test_validate.py
- pytest passes at HEAD; every mutant is killed at HEAD
