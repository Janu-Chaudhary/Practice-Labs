#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file cart.py 'def total(items): return sum(items)' "Add cart"
printf 'def discount(total): return total * 0.9\n' > discount.py
printf 'DEBUG 12:00:01 cart total=100\nDEBUG 12:00:02 discount=10\n' > debug.log
git add discount.py debug.log
git commit -q -m "Add discount"
banner "04 undo the last commit but keep the work (reset --soft)"
