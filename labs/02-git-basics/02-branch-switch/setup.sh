#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file README.md '# Shop' "Add readme"
commit_file app.py 'print("shop")' "Add app"
banner "branches: create, switch, commit on the right one"
