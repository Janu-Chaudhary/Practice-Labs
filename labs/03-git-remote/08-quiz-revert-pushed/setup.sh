#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file auth.py $'def is_allowed(user):\n    return user.is_logged_in' "Add auth check"
commit_file orders.py $'def list_orders():\n    return []' "Add orders route"
commit_file auth.py $'def is_allowed(user):\n    return True  # TODO remove, testing only' "Disable auth check"
commit_file orders.py $'def list_orders():\n    return []\n\ndef order_total(items):\n    return sum(items)' "Add order totals"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
git rev-parse main > .git/lab-pushed
banner "08 undo a commit that is already pushed (revert)"
