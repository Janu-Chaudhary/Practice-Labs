# Solution - 08-quiz-ci-pull-request

In the Files panel open `.github/workflows/ci.yml`. Add the `pull_request` trigger and delete the
`continue-on-error: true` line, so it reads:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
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

      - name: Run unit tests
        run: pytest -q
```
Save with Ctrl+S. Then:
```bash
python3 -c "import yaml; print(yaml.safe_load(open('.github/workflows/ci.yml')))"   # quick syntax check
git add .github/workflows/ci.yml
git commit -m "Run CI on pull requests to main"
```
In the Files panel click **+ New file**, type `answer.txt`, and make it read (the job id is the key
under `jobs:`):
```
test
```
Save with Ctrl+S. Then:
```bash
cd .. && ./check.sh
```

Why:
- `push: branches: [main]` runs CI only after code is already on main - too late.
  `pull_request: branches: [main]` runs CI on every PR that targets main, so the PR shows a check.
- `continue-on-error: true` makes a failing step count as success - it hides red tests.
- A red check is only a warning until branch protection (repo Settings -> Branches / Rulesets)
  marks the job `test` as a **required status check**. You need BOTH the trigger and the rule (quiz 2 Q3).
  Without the trigger, the required check never reports and every PR waits forever.

Common wrong attempts:
- `pull_request:` indented under `push:` -> becomes a key inside push, not a trigger. Both must be 2 spaces in.
- Writing `on: pull_request` (replacing push) -> push trigger lost.
- `branches: main` without brackets works in GitHub too; `[main]` is the list form.
- Tabs in YAML -> parse error.
