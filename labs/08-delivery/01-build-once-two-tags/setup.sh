#!/usr/bin/env bash
# Drill: commit first, then build ONE image with two tags: the version and the short commit id.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
SHOP="$LAB_DIR/../_shop"
# clean only what this lab creates (repository lab81-shop)
docker ps -a --format '{{.ID}} {{.Image}}' | awk '$2 ~ /^lab81-shop/ {print $1}' | xargs -r docker rm -f >/dev/null 2>&1
docker image ls -q lab81-shop 2>/dev/null | sort -u | xargs -r docker image rm -f >/dev/null 2>&1
fresh_work
git_repo
cp "$SHOP/server.js" "$SHOP/Dockerfile" .
git add server.js Dockerfile
git commit -q -m "TiffinGo 2.3"
printf 'node_modules\n' > .dockerignore
git add .dockerignore
git commit -q -m "Add dockerignore"
# the developer's uncommitted change for 2.4: a new item on the menu
sed -i 's/"lassi": 60 };/"lassi": 60, "veg biryani": 160 };/' server.js
banner "01-build-once-two-tags (Drill): commit, then build lab81-shop:2.4 + lab81-shop:<commit id>"
