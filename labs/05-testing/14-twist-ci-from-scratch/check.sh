#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 14-twist-ci-from-scratch  (reads the COMMITTED files)"
export PYTHONDONTWRITEBYTECODE=1 PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
F=.github/workflows/ci.yml
# run_at <rev> <command>: run a shell command in a clean copy of <rev> (like CI's fresh checkout)
run_at() {
  local rev=$1 t rc; shift
  git rev-parse -q --verify "$rev^{commit}" >/dev/null || return 1
  t=$(mktemp -d)
  git archive "$rev" | tar -x -C "$t"
  (cd "$t" && eval "$@" 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
# wf <python-condition>: parse the committed workflow with PyYAML and test a condition.
# YAML 1.1 reads the bare key  on  as the boolean True, so look up both "on" and True.
wf() {
  git show "HEAD:$F" | python3 -c '
import sys, yaml
w = yaml.safe_load(sys.stdin)
on = w.get("on", w.get(True)) or {}
if isinstance(on, str): on = {on: None}
if isinstance(on, list): on = {k: None for k in on}
def branches(ev):
    v = on.get(ev)
    return (v or {}).get("branches") if isinstance(v, dict) or v is None else None
jobs = w.get("jobs") or {}
job = jobs.get("build-and-test") or {}
steps = job.get("steps") or []
def idx(pred):
    for i, s in enumerate(steps):
        if pred(s): return i
    return -1
uses = lambda name: (lambda s: str(s.get("uses", "")).startswith(name))
runs = lambda text: (lambda s: text in str(s.get("run", "")))
order = [idx(uses("actions/checkout")), idx(uses("actions/setup-python")),
         idx(runs("pip install -r requirements.txt")), idx(runs("ruff check")), idx(runs("pytest"))]
sys.exit(0 if ('"$1"') else 1)'
}
# simulate_ci: run every run: step of the committed workflow, in order, in a clean copy of HEAD.
# pip install steps are skipped (no network here); any other failing step fails the "job".
simulate_ci() {
  git show "HEAD:$F" | python3 -c '
import sys, yaml
w = yaml.safe_load(sys.stdin)
for s in w["jobs"]["build-and-test"]["steps"]:
    r = s.get("run")
    if r and "pip install" not in r: print(r.replace("\n", " ; "))' > "$WORK/.git/ci-steps" || return 1
  [ -s "$WORK/.git/ci-steps" ] || return 1
  run_at HEAD 'set -e; while IFS= read -r cmd; do echo "+ $cmd"; bash -ec "$cmd"; done < "'"$WORK"'/.git/ci-steps"'
}
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
HAVE_RUFF=1; command -v ruff >/dev/null || HAVE_RUFF=0
check "on main, exactly 2 new commits" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 3 ] && [ "$(git rev-parse HEAD~2)" = "$BASE" ]'
check "commit 1 (HEAD~1) changed exactly temps.py and requirements.txt" '[ "$(git diff --name-only HEAD~2 HEAD~1 | sort | tr "\n" " ")" = "requirements.txt temps.py " ]'
check "commit 2 (HEAD) added only .github/workflows/ci.yml" '[ "$(git diff --name-only HEAD~1 HEAD)" = "$F" ]'
check "requirements.txt lists pytest and ruff (CI starts from a clean machine)" 'git show HEAD:requirements.txt | grep -qx "pytest.*" && git show HEAD:requirements.txt | grep -qx "ruff.*"'
check "test_temps.py unchanged" 'git diff --quiet "$BASE" HEAD -- test_temps.py'
if [ $HAVE_RUFF = 1 ]; then
  check "ruff check . passes at HEAD~1 (lint fixed before CI was added)" 'run_at HEAD~1 "ruff check --no-cache ." >/dev/null'
else
  echo "  (ruff not installed here: checking the two lint errors with grep instead)"
  check "lint errors fixed at HEAD~1 (no import os, no unused total)" '! git show HEAD~1:temps.py | grep -q "^import os" && { git show HEAD~1:temps.py | grep -q "return total" || ! git show HEAD~1:temps.py | grep -q "total = "; }'
fi
check "pytest passes at HEAD~1" 'run_at HEAD~1 "python3 -m pytest -q -p no:cacheprovider" >/dev/null'
if python3 -c "import yaml" 2>/dev/null; then
  check "ci.yml is valid YAML" 'wf "True"'
  check "runs on pull_request to main" 'wf "\"main\" in (branches(\"pull_request\") or [])"'
  check "runs on push to main" 'wf "\"main\" in (branches(\"push\") or [])"'
  check "has a job with id build-and-test that runs-on ubuntu-latest" 'wf "job and job.get(\"runs-on\") == \"ubuntu-latest\""'
  check "steps: checkout, setup-python, pip install -r requirements.txt, ruff check, pytest (in that order)" 'wf "-1 not in order and order == sorted(order)"'
  check "setup-python sets a python-version" 'wf "any(str(s.get(\"uses\",\"\")).startswith(\"actions/setup-python\") and (s.get(\"with\") or {}).get(\"python-version\") for s in steps)"'
  check "nothing hides failures (no continue-on-error, no || true)" 'wf "not job.get(\"continue-on-error\") and not any(s.get(\"continue-on-error\") or \"|| true\" in str(s.get(\"run\",\"\")) for s in steps)"'
  if [ $HAVE_RUFF = 1 ]; then
    check "simulated CI run: every run: step (except pip install) succeeds on HEAD" 'simulate_ci'
  fi
else
  echo "  ${R}PyYAML is missing (python3 -c 'import yaml' fails): install it with  pip install pyyaml  to check ci.yml${N}"
  check "PyYAML available to parse ci.yml" 'false'
fi
check "no uncommitted changes to tracked files" 'git diff --quiet HEAD'
summary
