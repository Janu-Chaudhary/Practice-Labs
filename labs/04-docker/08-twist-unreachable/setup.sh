#!/usr/bin/env bash
# Twist: port is published, container is Up, but curl gets nothing (server bound to 127.0.0.1).
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker rm -f inventory >/dev/null 2>&1
docker ps -aq --filter ancestor=inventory:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker ps -aq --filter ancestor=inventory:1.1 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f inventory:1.0 inventory:1.1 >/dev/null 2>&1
fresh_work
cat > server.js <<'JS'
const http = require("node:http");
const HOST = "127.0.0.1";
const PORT = 3000;
http.createServer((req, res) => {
  if (req.url === "/health") return res.end("ok\n");
  res.end(JSON.stringify({ items: ["bolt", "nut", "washer"] }) + "\n");
}).listen(PORT, HOST, () => console.log(`inventory listening on ${HOST}:${PORT}`));
JS
printf 'node_modules\n.git\n' > .dockerignore
cat > Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js ./
CMD ["node", "server.js"]
DF
echo "Building inventory:1.0 and starting container inventory on port 8083..."
docker build -q -t inventory:1.0 . >/dev/null || { echo "build failed"; exit 1; }
docker run -d --name inventory -p 8083:3000 inventory:1.0 >/dev/null
banner "08-twist-unreachable (Twist): inventory is Up but curl localhost:8083 fails"
