#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file README.md '# Notes app' "Add README"
git switch -q -c feature
commit_file notes.py $'def add_note(text):\n    return text' "Add notes"
commit_file notes.py $'def add_note(text):\n    return text.strip()' "Strip whitespace in notes"
git rev-parse feature > .git/lab-old-feature
git switch -q main
commit_file CHANGELOG.md $'# Changelog\n- notes feature coming' "Update changelog"
git rev-parse main > .git/lab-main
banner "07 (quiz 2 Q1) rebase feature onto main"
