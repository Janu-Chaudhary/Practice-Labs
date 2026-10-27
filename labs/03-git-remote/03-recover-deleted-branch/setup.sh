#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py 'print("shop")' "Add app"
git switch -q -c payments
commit_file payment.py 'class Payment: pass' "Add payment model"
commit_file refund.py 'def refund(p): return True' "Add refund handler"
git switch -q main
git branch -q -D payments
banner "03 recover a branch deleted with git branch -D"
