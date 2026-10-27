# 05-testing / 14 - Write a CI workflow from scratch, with a lint gate  (Twist, hard)

```
$ git log --oneline
xxxxxxx (HEAD -> main) Add temperature helpers
$ ls -a
.  ..  .git  .gitignore  requirements.txt  temps.py  test_temps.py
$ pytest -q
3 passed
```

## Situation
The repo has no CI at all. The team wants every pull request into `main` (and every push to `main`)
checked on a fresh GitHub machine with: **install -> lint -> unit tests**, like the lecture's
"complete GitHub Actions workflow". The linter is `ruff` (`ruff check .` exits 1 when it finds a problem,
so a lint error fails the job just like a failing test).

Two things will bite you if you only write the YAML:
- `ruff check .` is **not clean** right now. Run it and read the two errors.
- CI starts from a **clean machine**: it only has what `requirements.txt` installs. Look at that file.

## Task
Exactly two new commits on `main`, in this order:
1. Make the project lint-clean and installable: fix the two ruff errors in `temps.py` (keep the
   behaviour the same; the tests must still pass) and add `ruff` to `requirements.txt`.
   Commit only `temps.py` and `requirements.txt`.
2. Create `.github/workflows/ci.yml` (you need `mkdir -p .github/workflows` first):
   - triggers: `pull_request` to `main` **and** `push` to `main`
   - one job with id `build-and-test`, `runs-on: ubuntu-latest`
   - steps in this order: check out the code (`actions/checkout@v4`), set up Python
     (`actions/setup-python@v5` with a `python-version`), `pip install -r requirements.txt`,
     `ruff check .`, `pytest`
   - a failing lint or test step must fail the job: no `continue-on-error`, no `|| true`
   Commit only that file.

Before committing, run locally exactly what CI will run: `ruff check .` and `pytest`.
Check your YAML parses: `python3 -c "import yaml; print(yaml.safe_load(open('.github/workflows/ci.yml')))"`

## Stop
- Don't edit `test_temps.py`. Don't push. No extra commits.
- Why the order matters: if you commit the workflow first, its very first CI run would be red.

## What will be checked
- 3 commits; HEAD~1 = temps.py + requirements.txt only; HEAD = ci.yml only; test_temps.py unchanged
- requirements.txt has `pytest` and `ruff`; at HEAD~1 `ruff check .` and `pytest` both pass
- ci.yml parses; pull_request + push to main; job `build-and-test` on ubuntu-latest
- steps present and in order: checkout, setup-python (with python-version), pip install -r
  requirements.txt, ruff check, pytest; nothing hides failures
- a simulated CI run: every `run:` step of your workflow (except pip install) is executed in a clean
  copy of HEAD and must succeed
