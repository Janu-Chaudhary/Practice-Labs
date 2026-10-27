#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# our 6 instructions after FROM, oldest first (docker history lists newest first)
steps() { docker history --no-trunc --format '{{.CreatedBy}}' shop-api:1.0 | head -6 | tac; }
pos() { steps | grep -n -E "$1" | head -1 | cut -d: -f1; }
orig='CMD ["node", "server.js"]
COPY . .
COPY package.json package-lock.json ./
EXPOSE 3000
FROM node:24-alpine
RUN npm ci
WORKDIR /app'
check "Dockerfile only reordered (same 7 lines, nothing added/removed)" '[ "$(grep -v "^[[:space:]]*$" Dockerfile | sed "s/[[:space:]]*$//" | LC_ALL=C sort)" = "$(printf "%s\n" "$orig" | LC_ALL=C sort)" ]'
check "image shop-api:1.0 was built" 'docker image inspect shop-api:1.0'
check "built with COPY package.json package-lock.json ./, then RUN npm ci" 'a=$(pos "^COPY package.json package-lock.json"); b=$(pos "^RUN .*npm ci"); [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]'
check "built with RUN npm ci, then COPY . ." 'b=$(pos "^RUN .*npm ci"); c=$(pos "^COPY \. \."); [ -n "$b" ] && [ -n "$c" ] && [ "$b" -lt "$c" ]'
check "no container was run from shop-api:1.0" 'docker image inspect shop-api:1.0 >/dev/null && [ -z "$(docker ps -aq --filter ancestor=shop-api:1.0)" ]'
summary
