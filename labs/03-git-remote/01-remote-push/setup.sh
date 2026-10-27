#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py 'print("orders api")' "Add app"
commit_file test_app.py 'def test_ok(): assert True' "Add tests"
# an empty bare repo stands in for GitHub
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
banner "01 remote + push: connect origin and push main"
