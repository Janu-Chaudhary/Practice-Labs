# 05-testing / 01 - Run pytest and read the output  (Drill)

## Situation
You joined a team. The repo has `cart.py` and `test_cart.py`. Someone says "one test is red".
Before fixing anything, you must be able to read what pytest tells you.

## Task
1. Inside `work/`, run the test suite: `pytest`
2. Right after, print the exit code: `echo $?`
3. Create `answer.txt` with exactly 4 lines:
   - line 1: the **name** of the failing test (e.g. `test_something`)
   - line 2: the **exit code** pytest returned
   - line 3: how many tests **passed**
   - line 4: the value that `total_with_tax([100])` **actually** returned (read it from the `assert ... == ...` line)

Create `answer.txt` in the Files panel: click **+ New file**, type `answer.txt`, write the 4 lines,
save with Ctrl+S.

## Stop
- Do NOT change `cart.py` or `test_cart.py`. This lab is only about reading output.

## What will be checked
- answer.txt line 1 = failing test name, line 2 = exit code, line 3 = number passed, line 4 = actual value
- cart.py and test_cart.py are unchanged
