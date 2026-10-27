# Solution - 01-run-pytest

```bash
cd work
pytest              # runs every test_*.py file; shows one F and the failure details
echo $?             # 1  -> "some tests failed" (0 = all passed, 5 = no tests collected, 2/4 = interrupted / usage error)
```
In the Files panel click **+ New file**, type `answer.txt`, and make it read:
```
test_total_with_tax_adds_15_percent
1
5
15.0
```
Save with Ctrl+S. Then:
```bash
cd .. && ./check.sh
```

How to read the output:
- `.....F` - one character per test: `.` pass, `F` fail, `E` error (crash in setup / import).
- `FAILED test_cart.py::test_total_with_tax_adds_15_percent - assert 15.0 == 115.0`
  -> left side `15.0` is what the code returned, right side `115.0` is what the test expected.
- Last line `1 failed, 5 passed` gives the counts.

Common wrong attempts:
- Running `echo $?` after another command (e.g. after `ls`) -> you get that command's exit code (0), not pytest's.
- Reading the 115.0 as "the actual value" -> no, in `assert X == Y` pytest shows the evaluated left side first; here the left side is the call.
- "Fixing" cart.py -> fails the last check. Reading first, fixing later is the point.
