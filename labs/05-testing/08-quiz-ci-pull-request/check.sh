#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 08-quiz-ci-pull-request  (reads the COMMITTED .github/workflows/ci.yml)"
F=.github/workflows/ci.yml
# wf <python-condition on w>: parse the committed workflow with PyYAML and test a condition.
# Note: YAML 1.1 reads the bare key  on  as the boolean True, so we look up both "on" and True.
wf() {
  git show "HEAD:$F" | python3 -c '
import sys, yaml
w = yaml.safe_load(sys.stdin)
on = w.get("on", w.get(True)) or {}
if isinstance(on, str): on = {on: None}
if isinstance(on, list): on = {k: None for k in on}
def branches(ev):
    v = on.get(ev) if isinstance(on, dict) else None
    if v is None: return None
    return v.get("branches") if isinstance(v, dict) else None
steps = [s for j in (w.get("jobs") or {}).values() for s in (j.get("steps") or [])]
sys.exit(0 if ('"$1"') else 1)'
}
if python3 -c "import yaml" 2>/dev/null; then
  check "workflow is valid YAML" 'wf "True"'
  check "runs on pull_request to main" 'wf "\"main\" in (branches(\"pull_request\") or [])"'
  check "still runs on push to main" 'wf "\"main\" in (branches(\"push\") or [])"'
  check "no step has continue-on-error: true" 'wf "not any(s.get(\"continue-on-error\") for s in steps)"'
  check "a step still runs pytest" 'wf "any(\"pytest\" in str(s.get(\"run\",\"\")) for s in steps)"'
else
  echo "  (PyYAML not installed: using simpler grep checks)"
  check "pull_request trigger present" 'git show HEAD:$F | grep -Eq "^  pull_request:"'
  check "push trigger present" 'git show HEAD:$F | grep -Eq "^  push:"'
  check "no continue-on-error: true" '! git show HEAD:$F | grep -q "continue-on-error: *true"'
  check "a step still runs pytest" 'git show HEAD:$F | grep -q "run: *pytest"'
fi
check "exactly one new commit (2 in total) on main" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 2 ] && [ "$(git rev-parse HEAD~1)" = "$(cat .git/lab-base)" ]'
check "ci.yml has no uncommitted changes" 'git diff --quiet HEAD -- $F'
check "answer.txt names the job to mark as a required status check" '[ "$(head -1 answer.txt 2>/dev/null | tr -d "[:space:]")" = test ]'
summary
