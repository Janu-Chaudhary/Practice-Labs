#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file greet.py 'def greet(name):
    return "Hello " + name' "Add greet"
banner "Quiz 1 Q16: fix-greeting branch with an f-string"
