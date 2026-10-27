# Solution - 04-select-tests

```bash
pytest -v                                        # all 6, one line each: test_users.py::name PASSED
pytest -k email                                  # 3 passed, 3 deselected
pytest test_users.py::test_password_too_short    # exactly that one test
pytest -k "password and not short"               # 1 passed, 5 deselected
cd .. && ./check.sh
```

Why:
- `-k EXPR` keeps tests whose name matches; `and`, `or`, `not` work; quote it when it has spaces.
- `file::test` is the test's "node id"; pytest prints it in `FAILED file::test` lines, so you can copy it.
- Other useful flags: `-q` (quiet), `-x` (stop at first failure), `-s` (show print output),
  `--lf` (rerun only last failures).

Common wrong attempts:
- `pytest -k password and not short` (no quotes) -> the shell splits it; pytest sees `and` as a file name -> error, exit code 4.
- `pytest test_password_too_short` -> pytest thinks it is a file/folder: `file or directory not found`.
- `pytest -k Email` -> -k is case-insensitive, so this still works; not a problem.
- If `-k` matches nothing -> `6 deselected`, exit code 5 ("no tests ran"). In CI that is a red build.
