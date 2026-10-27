#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file calc.py 'def add(a, b):
    return a + b' "Add add()"
git switch -q -c feature
commit_file calc.py 'def add(a, b):
    return a + b

def sub(a, b):
    return a - b' "Add sub()"
commit_file test_calc.py 'from calc import add, sub

def test_sub():
    assert sub(5, 2) == 3' "Test sub()"
git switch -q main
banner "merge: predict fast-forward, then merge feature into main"
