#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py $'def checkout(total):\n    return total' "Add app"
git rev-parse HEAD > .git/lab-base
git switch -q -c discount
commit_file discount.py $'def apply_discount(total):\n    return total * 0.9' "Add discount module"
commit_file app.py $'from discount import apply_discount\n\ndef checkout(total):\n    return apply_discount(total)' "Use discount at checkout"
git switch -q main
commit_file README.md '# Shop API' "Add README"
git merge -q --no-ff --no-edit discount
git rev-parse HEAD > .git/lab-merge
git branch -q -D discount
commit_file logging.cfg 'level=INFO' "Add logging config"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
git rev-parse main > .git/lab-pushed
banner "12 a merged (and pushed) feature broke checkout: undo the whole merge without rewriting history"
