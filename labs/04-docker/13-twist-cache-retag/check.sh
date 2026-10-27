#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
id() { docker image inspect -f '{{.Id}}' "$1" 2>/dev/null; }
# build steps of lab13-shop:1.2 after FROM, oldest first (docker history lists newest first)
steps() { docker history --no-trunc --format '{{.CreatedBy}}' lab13-shop:1.2 | head -7 | tac; }
pos() { steps | grep -n -E "$1" | head -1 | cut -d: -f1; }
# build-1.2.log (plain progress): the "#N" id of a step, and whether "#N CACHED" follows
stepid() { grep -E "^#[0-9]+ \[[^]]+\] $1" build-1.2.log | head -1 | cut -d' ' -f1; }
cached() { local n; n=$(stepid "$1"); [ -n "$n" ] && grep -qx "$n CACHED" build-1.2.log; }
check ".dockerignore keeps out logs and node_modules" '[ -f .dockerignore ] && grep -qE "^/?logs/?[[:space:]]*$" .dockerignore && grep -qE "^/?node_modules/?[[:space:]]*$" .dockerignore'
check "images lab13-shop:1.1 and lab13-shop:1.2 exist" 'docker image inspect lab13-shop:1.1 lab13-shop:1.2'
check "1.1 serves \"shop 1.1\" code, 1.2 serves \"shop 1.2\" code" 'docker run --rm lab13-shop:1.1 grep -q "VERSION = \"1.1\"" /app/server.js && docker run --rm lab13-shop:1.2 grep -q "VERSION = \"1.2\"" /app/server.js'
check "1.2 was built with COPY package*.json first, then RUN npm ci, then COPY . ." 'a=$(pos "^COPY package"); b=$(pos "^RUN .*npm ci"); c=$(pos "^COPY \. \."); [ -n "$a" ] && [ -n "$b" ] && [ -n "$c" ] && [ "$a" -lt "$b" ] && [ "$b" -lt "$c" ]'
check "1.2 has no /app/logs and no host node_modules inside" 'docker image inspect lab13-shop:1.2 >/dev/null && docker run --rm lab13-shop:1.2 sh -c "test ! -e /app/logs && test ! -e /app/node_modules/left-from-host"'
check "build-1.2.log: RUN npm ci came from the cache (CACHED)" '[ -f build-1.2.log ] && cached "RUN .*npm ci"'
check "build-1.2.log: COPY . . really ran again (server.js changed)" '[ -f build-1.2.log ] && n=$(stepid "COPY \. \."); [ -n "$n" ] && ! grep -qx "$n CACHED" build-1.2.log'
check "lab13-shop:latest is the same image as 1.2" 'a=$(id lab13-shop:latest); [ -n "$a" ] && [ "$a" = "$(id lab13-shop:1.2)" ]'
check "lab13-shop:stable is the same image as 1.1" 'a=$(id lab13-shop:stable); [ -n "$a" ] && [ "$a" = "$(id lab13-shop:1.1)" ]'
check "old tag lab13-shop:1.0 was removed" '! docker image inspect lab13-shop:1.0'
check "no containers left from lab13-shop images" 'docker image inspect lab13-shop:1.2 >/dev/null && for t in 1.1 1.2 latest stable; do [ -z "$(docker ps -aq --filter ancestor=lab13-shop:$t)" ] || exit 1; done'
summary
