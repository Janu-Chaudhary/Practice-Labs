#!/usr/bin/env bash
# Quiz-style: recreates Quiz 2 Q15 (reorder a broken Dockerfile for a working build + good layer cache).
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker ps -aq --filter ancestor=shop-api:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f shop-api:1.0 >/dev/null 2>&1
fresh_work
printf 'node_modules\n' > .dockerignore
cat > Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
RUN npm ci
COPY package.json package-lock.json ./
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
DF
echo '{"lockfileVersion": 3}' > package-lock.json
echo '{"name": "shop-api", "version": "1.0.0"}' > package.json
echo 'console.log("shop-api listening on 0.0.0.0:3000")' > server.js
docker image inspect node:24-alpine >/dev/null 2>&1 || docker pull -q node:24-alpine >/dev/null
banner "06-quiz-shop-api-order (Quiz-style, Quiz 2 Q15): reorder the Dockerfile, build shop-api:1.0"
