#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
img() { docker image inspect -f '{{.Id}}' "$1" 2>/dev/null; }
echo "Checking..."
check "main has 3 commits, the last one is \"Add veg biryani to menu\"" '[ "$(git rev-list --count main)" -eq 3 ] && [ "$(git log -1 --format=%s main)" = "Add veg biryani to menu" ]'
check "server.js at main has veg biryani; nothing left uncommitted" 'git show main:server.js | grep -q "veg biryani" && [ -z "$(git status --porcelain)" ]'
check "image lab81-shop:2.4 exists" '[ -n "$(img lab81-shop:2.4)" ]'
check "image lab81-shop:<short id of HEAD> exists (git rev-parse --short HEAD)" '[ -n "$(img lab81-shop:$(git rev-parse --short HEAD))" ]'
check "both tags point to the SAME image id (built once)" 'a=$(img lab81-shop:2.4); b=$(img lab81-shop:$(git rev-parse --short HEAD)); [ -n "$a" ] && [ "$a" = "$b" ]'
check "the image was built with --build-arg RELEASE=2.4 (ENV RELEASE=2.4 inside)" 'docker image inspect -f "{{range .Config.Env}}{{println .}}{{end}}" lab81-shop:2.4 | grep -qx "RELEASE=2.4"'
check "the image contains the committed code (veg biryani in /app/server.js)" 'docker run --rm lab81-shop:2.4 grep -q "veg biryani" /app/server.js'
check "lab81-shop has exactly these two tags (no stray :latest or old-commit tag)" '[ "$(docker image ls lab81-shop --format "{{.Tag}}" | sort | tr "\n" " ")" = "$(printf "%s\n" 2.4 "$(git rev-parse --short HEAD)" | sort | tr "\n" " ")" ]'
summary
