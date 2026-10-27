# 05-testing / 08 - Fix a CI workflow  (Quiz-style)

## Situation
`.github/workflows/ci.yml` runs only on **push to main**. A teammate opened a pull request with a
failing test: GitHub showed **no checks** on the PR, a reviewer merged it, and main went red.
Also, someone added `continue-on-error: true` to the test step "to make CI green".

## Task
Open `.github/workflows/ci.yml` in the Files panel (save with Ctrl+S when done):
1. Add a `pull_request` trigger for `main` (keep the push trigger).
2. Make a failing test fail the job again.
3. Commit the change (one commit, any message).
4. Create `answer.txt` (Files panel, **+ New file**) with one line: the **job id** you would select as the *required status check*
   in GitHub's branch protection rules. (That part is a GitHub setting, not YAML. You can't do it here.)

Careful: YAML indentation is spaces only, and siblings must line up exactly.

## Stop
- One new commit only. Don't push (there is no remote).

## What will be checked
- committed ci.yml parses; has pull_request -> branches [main] and push -> branches [main]
- no step has continue-on-error: true; a step still runs pytest
- exactly one new commit; ci.yml committed
- answer.txt line 1 = the job id
