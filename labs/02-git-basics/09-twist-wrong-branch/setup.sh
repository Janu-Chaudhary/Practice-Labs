#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file greet.py 'def greet(name):
    return f"Hello, {name}!"' "Add greet"
commit_file login.py 'def login_form():
    return ["user", "password"]' "Add login form"
commit_file login.py 'def login_form():
    return ["user", "password"]

def valid(user, pw):
    return bool(user) and len(pw) >= 8' "Validate login fields"
banner "Twist: two commits landed on main by mistake"
