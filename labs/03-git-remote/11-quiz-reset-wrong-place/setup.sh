#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py $'def handle(request):\n    return "ok"' "Add app"
commit_file README.md '# Ordres API' "Add README"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
git rev-parse main > .git/lab-pushed
commit_file cart.py $'def cart_total(items):\n    return sum(items)' "Add cart"
git rev-parse HEAD > .git/lab-cart
commit_file discount.py $'def apply_discount(total, pct):\n    return total * (100 - pct) / 100' "Add discount"
git rev-parse HEAD > .git/lab-discount
# the mistake: meant to throw away an uncommitted experiment, typed the wrong target
echo "experiment" > scratch.txt
git reset -q --hard origin/main
rm -f scratch.txt
# ...and then kept working without noticing
commit_file README.md '# Orders API' "Fix typo in README"
git rev-parse HEAD > .git/lab-typo
banner "11 reset --hard to the wrong place, then committed on top: recover and push"
