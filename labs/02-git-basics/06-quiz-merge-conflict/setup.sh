#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file greet.py 'def greet(name):
    return f"Hello, {name}!"' "Add greet"
git switch -q -c feature
commit_file greet.py 'def greet(name):
    return f"Hi there, {name}."' "Use friendlier greeting"
git switch -q main
commit_file greet.py 'def greet(name):
    return f"Hello, {name}! Welcome back."' "Welcome returning users"
banner "Quiz 1 Q17: merge feature into main, resolve the conflict"
