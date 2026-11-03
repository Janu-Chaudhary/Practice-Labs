#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
echo "Checking 09-load/04-quiz-pool-sizing"
export PYTHONDONTWRITEBYTECODE=1 PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
# pytest_at <rev> [pools.toml text]: run the suite of <rev>, optionally with pools.toml replaced
pytest_at() {
  local t rc; t=$(mktemp -d)
  git archive "$1" | tar -x -C "$t"
  [ $# -ge 2 ] && printf '%s\n' "$2" > "$t/pools.toml"
  (cd "$t" && python3 -m pytest -q -p no:cacheprovider 2>&1); rc=$?
  rm -rf "$t"; return $rc
}
# toml <app pool> <app timeout line> <worker pool> <worker timeout line>
toml() {
  printf '[database]\nmax_connections = 100\nspare = 10\n\n[app]\nservers_now = 6\nservers_max = 8\npool_size = %s\n%s\n\n[reporting_worker]\ninstances = 1\npool_size = %s\n%s\n' "$1" "$2" "$3" "$4"
}
GOOD=$(toml 10 'wait_timeout_ms = 2000' 5 'wait_timeout_ms = 2000')
NOW_ONLY=$(toml 14 'wait_timeout_ms = 2000' 5 'wait_timeout_ms = 2000')
NO_WORKER_TO=$(toml 10 'wait_timeout_ms = 2000' 5 '')
APP_TO_ZERO=$(toml 10 'wait_timeout_ms = 0' 5 'wait_timeout_ms = 2000')
VALUES='
import subprocess, tomllib
c = tomllib.loads(subprocess.run(["git", "show", "HEAD:pools.toml"], capture_output=True, text=True, check=True).stdout)
a, w, d = c["app"], c["reporting_worker"], c["database"]
assert (d["max_connections"], d["spare"], a["servers_now"], a["servers_max"], w["instances"]) == (100, 10, 6, 8, 1), "changed fixed values"
assert w["pool_size"] == 5, "worker pool"
assert a["wait_timeout_ms"] == 2000 and w["wait_timeout_ms"] == 2000, "timeouts"
'
POOL='
import subprocess, tomllib
c = tomllib.loads(subprocess.run(["git", "show", "HEAD:pools.toml"], capture_output=True, text=True, check=True).stdout)
assert c["app"]["pool_size"] == 10, c["app"]["pool_size"]
'
BASE=$(cat "$WORK/.git/lab-base" 2>/dev/null)
TWO=$(printf 'pools.toml\ntest_pools.py')
check "on main, exactly 2 commits, built on the original" '[ "$(git branch --show-current)" = main ] && [ $(git rev-list --count HEAD) -eq 2 ] && [ "$(git rev-parse HEAD~1)" = "$BASE" ]'
check "new commit changes exactly pools.toml and test_pools.py; message contains \"pool\"" '[ "$(git diff --name-only HEAD~1 HEAD | sort)" = "$TWO" ] && git log -1 --format=%B | grep -qi pool'
check "budget.py unchanged" 'git diff --quiet "$BASE" HEAD -- budget.py && git diff --quiet "$BASE" -- budget.py'
check "worker pool 5, both wait_timeout_ms = 2000, fixed values untouched" 'python3 -c "$VALUES"'
check "app pool_size = largest that fits 8 servers (8 x p + 5 <= 90)" 'python3 -c "$POOL"'
check "pytest passes at HEAD (at least 2 tests)" 'pytest_at HEAD | grep -Eq "^([2-9]|[1-9][0-9]+) passed"'
check "your tests pass on a known-good config" 'pytest_at HEAD "$GOOD" >/dev/null'
check "your tests FAIL when pool fits only servers_now (6 x 14 + 5)" '! pytest_at HEAD "$NOW_ONLY" >/dev/null'
check "your tests FAIL when the worker has no wait_timeout_ms" '! pytest_at HEAD "$NO_WORKER_TO" >/dev/null'
check "your tests FAIL when the app wait_timeout_ms is 0" '! pytest_at HEAD "$APP_TO_ZERO" >/dev/null'
summary
