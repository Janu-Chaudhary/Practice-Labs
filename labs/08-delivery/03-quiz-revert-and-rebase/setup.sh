#!/usr/bin/env bash
# Quiz-style: roll back by reverting the bad commit (new commit, exact message), while a teammate
# has pushed meanwhile: push is rejected -> git pull --rebase -> push. Linear history, no force.
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
cat > app.py <<'PY'
TIMEOUT_SECONDS = 10

MENU = {"paneer thali": 180, "lassi": 60}


def checkout(customer, group=False):
    items = ["paneer thali", "lassi"]
    total = sum(MENU[i] for i in items)
    return {"customer": customer, "total": total, "kind": "single"}
PY
git add app.py; git commit -q -m "Add checkout"
cat > app.py <<'PY'
TIMEOUT_SECONDS = 10

MENU = {"paneer thali": 180, "lassi": 60}
GROUPS = {"asha": ["asha", "ravi", "meena"]}


def checkout(customer, group=False):
    items = ["paneer thali", "lassi"]
    if group:
        items = ["paneer thali" for _ in GROUPS[customer]]  # KeyError: no saved group
    total = sum(MENU[i] for i in items)
    return {"customer": customer, "total": total, "kind": "group" if group else "single"}
PY
git add app.py; git commit -q -m "Add group orders"
commit_file footer.txt "TiffinGo - fresh tiffins since 2019" "Update footer text"
# the shared repo
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
# a teammate pushes while you look at the incident (you have NOT fetched it)
TM=$(mktemp -d)
git clone -q remote.git "$TM/tm"
git -C "$TM/tm" config user.name "Teammate"
git -C "$TM/tm" config user.email "teammate@example.com"
sed -i 's/^TIMEOUT_SECONDS = 10$/TIMEOUT_SECONDS = 30/' "$TM/tm/app.py"
git -C "$TM/tm" commit -q -am "Raise timeout to 30 seconds"
git -C "$TM/tm" push -q origin main
rm -rf "$TM"
banner "03-quiz-revert-and-rebase (Quiz-style): undo \"Add group orders\" with a revert and ship it"
