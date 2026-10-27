#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file notes.txt '# Team notes
- standup at 9:30
- deploy on Fridays is banned
- use feature branches
- review every PR' "Add notes"
git switch -q -c feature
commit_file notes.txt '# Team notes (v2)
- standup at 9:30
- deploy on Fridays is banned
- use feature branches
- review every PR' "Rename notes heading"
git switch -q main
commit_file app.py 'print("app")' "Add app"
# uncommitted work in progress on main
printf '%s\n' '- WIP: write on-call rota' >> notes.txt
banner "stash: park your edit, merge, bring it back"
