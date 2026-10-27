#!/usr/bin/env bash
# Twist: restructure a Dockerfile for the layer cache, keep junk out with .dockerignore, prove CACHED
# from build output, then tag/retag (latest + stable) and remove the old tag.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean what this lab creates: every image carrying our label (tagged or dangling) + their containers
for id in $(docker image ls -aq --filter label=course.lab=lab13 2>/dev/null | sort -u); do
  docker ps -aq --filter ancestor=$id 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
done
docker image rm -f lab13-shop:1.0 lab13-shop:1.1 lab13-shop:1.2 lab13-shop:latest lab13-shop:stable >/dev/null 2>&1
docker image ls -aq --filter label=course.lab=lab13 2>/dev/null | sort -u | xargs -r docker image rm -f >/dev/null 2>&1
fresh_work
cat > package.json <<'J'
{"name":"shop","version":"1.0.0","private":true,
 "scripts":{"start":"node server.js"}}
J
cat > package-lock.json <<'J'
{
  "name": "shop",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": { "name": "shop", "version": "1.0.0" }
  }
}
J
cat > server.js <<'JS'
const http = require("node:http");
const VERSION = "1.0";
http.createServer((req, res) => res.end(`shop ${VERSION}\n`))
  .listen(3000, "0.0.0.0", () => console.log(`shop ${VERSION} listening on 3000`));
JS
cat > Dockerfile <<'DF'
FROM node:24-alpine
LABEL course.lab=lab13
WORKDIR /app
COPY . .
RUN npm ci --omit=dev
EXPOSE 3000
CMD ["node", "server.js"]
DF
# junk that lives in the project folder but must never go into an image
mkdir -p logs node_modules/left-from-host
head -c 30000000 /dev/zero > logs/access-2026-10.log
echo "built on a laptop, wrong OS" > node_modules/left-from-host/index.js
docker image inspect node:24-alpine >/dev/null 2>&1 || docker pull -q node:24-alpine >/dev/null
echo "Building the old lab13-shop:1.0 ..."
docker build -q -t lab13-shop:1.0 . >/dev/null || { echo "build failed"; exit 1; }
banner "13-twist-cache-retag (Twist): fast rebuilds, small context, clean tags"
