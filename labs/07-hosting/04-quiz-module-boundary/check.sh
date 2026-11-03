#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
ROOTC='$(git rev-list --max-parents=0 HEAD)'
check "the whole test suite passes (pytest)" 'python3 -m pytest -q -p no:cacheprovider'
check "boundary test passes on its own" 'python3 -m pytest -q -p no:cacheprovider tests/test_boundaries.py'
check "billing/invoice.py no longer touches _store or USERS_TABLE" '! grep -qE "_store|USERS_TABLE" shop/billing/invoice.py'
check "billing/invoice.py imports the users public API" 'grep -qE "^(from shop\.users\.api import|from shop\.users import api|import shop\.users\.api)" shop/billing/invoice.py'
check "tests/, shop/users/ and pytest.ini were not changed (no silencing the check)" "git diff --quiet $ROOTC HEAD -- tests shop/users pytest.ini && git diff --quiet -- tests shop/users pytest.ini"
check "exactly one new commit on main" '[ "$(git rev-list --count main)" -eq 2 ] && [ "$(git branch --show-current)" = main ]'
check "commit message is: billing: use users public API" '[ "$(git log -1 --format=%s)" = "billing: use users public API" ]'
check "the commit changes only shop/billing/invoice.py" '[ "$(git diff --name-only HEAD~1 HEAD)" = shop/billing/invoice.py ]'
check "working tree clean (the fix is committed)" '[ -z "$(git status --porcelain)" ]'
summary
