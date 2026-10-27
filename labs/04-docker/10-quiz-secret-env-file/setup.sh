#!/usr/bin/env bash
# Quiz-style (harder): a secret was baked into an image (ENV + COPY . . with no .dockerignore).
# Rebuild without it, pass config at run time with --env-file, remove the leaky tag.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean what this lab creates (only lab10-* names)
docker rm -f lab10-payments >/dev/null 2>&1
for t in 1.0 1.1; do docker ps -aq --filter ancestor=lab10-payments:$t 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1; done
docker image rm -f lab10-payments:1.0 lab10-payments:1.1 >/dev/null 2>&1
fresh_work
cat > package.json <<'J'
{"name":"payments","version":"1.0.0","private":true,
 "scripts":{"start":"node server.js"}}
J
cat > package-lock.json <<'J'
{
  "name": "payments",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": { "name": "payments", "version": "1.0.0" }
  }
}
J
cat > server.js <<'JS'
const http = require("node:http");
// Factor III: config comes from the environment, read fresh every time the process starts.
const { DB_HOST, DB_PASSWORD } = process.env;
if (!DB_HOST || !DB_PASSWORD) {
  console.error("FATAL: DB_HOST and DB_PASSWORD must be set in the environment");
  process.exit(1);
}
http.createServer((req, res) => {
  if (req.url === "/health") return res.end(`payments ok db=${DB_HOST} password=set\n`);
  res.end("payments service\n");
}).listen(3000, "0.0.0.0", () => console.log(`payments listening on 3000 (db=${DB_HOST})`));
JS
printf 'DB_HOST=db.internal\nDB_PASSWORD=Summer2024!\n' > .env
cat > Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
ENV DB_HOST=db.internal
ENV DB_PASSWORD=Summer2024!
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
DF
docker image inspect node:24-alpine >/dev/null 2>&1 || docker pull -q node:24-alpine >/dev/null
echo "Building the teammate's leaky image lab10-payments:1.0 ..."
docker build -q -t lab10-payments:1.0 . >/dev/null || { echo "build failed"; exit 1; }
banner "10-quiz-secret-env-file (Quiz-style): get the password out of the image, pass it with --env-file"
