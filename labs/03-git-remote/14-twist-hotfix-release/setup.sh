#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
commit_file app.py $'def handle(request):\n    return "ok"' "Add app"
commit_file price.py $'def final_price(x):\n    return round(x)' "Add price"
git init -q --bare -b main remote.git
echo "remote.git/" >> .git/info/exclude
git remote add origin remote.git
git push -q -u origin main
# teammate (after your last fetch): cuts release-1.0 and pushes a feature to main
TM=$(mktemp -d); git clone -q remote.git "$TM/t"
( cd "$TM/t" && git config user.name Teammate && git config user.email tm@example.com \
  && git switch -q -c release-1.0 && commit_file version.txt '1.0' "Set version 1.0" \
  && git push -q origin release-1.0 && git rev-parse HEAD > "$WORK/.git/lab-release" \
  && git switch -q main && commit_file wishlist.py $'def wishlist():\n    return []' "Add wishlist" \
  && git push -q origin main && git rev-parse HEAD > "$WORK/.git/lab-teammate" )
rm -rf "$TM"
# you: a hotfix and a feature, both unpushed
commit_file price.py $'def final_price(x):\n    return round(x, 2)' "Fix price rounding"
commit_file theme.py 'DARK = True' "Add dark mode"
banner "14 hotfix: get main pushed (linear) and the fix ONLY onto release-1.0"
