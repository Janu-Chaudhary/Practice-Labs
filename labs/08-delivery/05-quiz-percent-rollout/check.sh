#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
GRADE="python3 $LAB_DIR/_grade.py"
export GRADE
echo "Checking..."
check "pytest: all tests in tests/ pass" 'python3 -m pytest -q -p no:cacheprovider tests'
check "rollout.py no longer uses random at all" '$GRADE rollout.py no-random'
check "bucket(flag, user) = first 4 bytes of sha256(\"flag:user\"), big-endian, % 100" '$GRADE rollout.py bucket-spec'
check "is_enabled(flag, user, percent) = bucket(flag, user) < percent" '$GRADE rollout.py enabled-spec'
check "tests/ unchanged (fix the code, not the tests)" 'git diff --quiet "$(cat .git/lab-tests-commit)" main -- tests pytest.ini && git diff --quiet -- tests'
check "main has 3 commits, the last is \"Use sticky hash buckets for rollout\"" '[ "$(git rev-list --count main)" -eq 3 ] && [ "$(git log -1 --format=%s main)" = "Use sticky hash buckets for rollout" ]'
check "the fix is committed (working tree clean)" '[ -z "$(git status --porcelain)" ]'
summary
