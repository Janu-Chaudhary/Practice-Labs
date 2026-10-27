# Solution - 14-twist-ci-from-scratch

Inside `work/`:
```bash
ruff check .                 # F401 `os` imported but unused ; F841 `total` assigned but never used
```
In the Files panel open `temps.py`: delete the line `import os` (and the blank lines after it), and
make `average` use its variable, so it reads:
```python
def c_to_f(c):
    return c * 9 / 5 + 32


def is_freezing(c):
    return c <= 0


def average(temps):
    total = sum(temps)
    return total / len(temps)
```
Save with Ctrl+S. Then open `requirements.txt` and add `ruff` on a new line (CI's clean machine
must install the linter too), so it reads:
```
pytest
ruff
```
Save with Ctrl+S. Then in the terminal:
```bash
ruff check .                    # All checks passed!
pytest -q                       # 3 passed
git add temps.py requirements.txt
git commit -m "Fix lint errors and add ruff to requirements"
```
Create the workflow: in the Files panel click **+ New file**, type `.github/workflows/ci.yml` (the
two folders are created for you), and make it read:
```yaml
name: CI
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Lint
        run: ruff check .
      - name: Run unit tests
        run: pytest
```
Save with Ctrl+S. Then:
```bash
python3 -c "import yaml; print(yaml.safe_load(open('.github/workflows/ci.yml')))"   # parses = no indent errors
git add .github/workflows/ci.yml
git commit -m "Add CI workflow: install, lint, test on PRs to main"
git log --oneline              # 3 commits
cd .. && ./check.sh
```

Why:
- `pull_request: branches: [main]` makes the check appear on the PR **before** merge; `push` catches
  anything that lands on main directly. (Blocking the merge still needs the GitHub "required status
  check" setting on `build-and-test`.)
- Steps run in order and the first non-zero exit code stops the job: lint before tests gives the fast
  feedback first. `ruff check .` exits 1 on findings, so lint is a real gate.
- The runner is a fresh VM: no ruff unless `requirements.txt` installs it -> "ruff: command not found",
  exit 127, red job.
- `- name:` starts a new list item (a step); `uses:`/`run:`/`with:` of the same step line up under `name`.
  YAML uses spaces only.
- The printed dict shows `True: {...}` instead of `'on'`: YAML 1.1 reads a bare `on` as a boolean.
  GitHub handles it; it is not your mistake.

Common wrong attempts:
- `ruff check . --fix` removes `import os` but NOT the F841 error (that fix is "unsafe", so ruff
  skips it): lint is still red. You must edit `average` yourself: `return total / len(temps)`.
- Deleting the line `total = sum(temps)` is also fine (behaviour the same); deleting `import os` only
  leaves F841 -> lint still red.
- `run: ruff check . || true` or `continue-on-error: true` on the lint step -> the job is green even
  with lint errors. Check fails "nothing hides failures".
- Typing only `ci.yml` in **+ New file** -> the file lands in `work/`, not in `.github/workflows/`, and
  GitHub would never run it. Type the whole path.
- `branches: main` under `pull_request` works on GitHub too, but write the list form `[main]`.
- Tabs for indentation -> `yaml.scanner.ScannerError: found character '\t'`.
- Committing everything in one commit -> check wants the lint fix first, then the workflow.
