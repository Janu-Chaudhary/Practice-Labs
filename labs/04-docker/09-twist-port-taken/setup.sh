#!/usr/bin/env bash
# Twist: deploy v2 when the port is already allocated AND the name is already in use.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker rm -f orders orders-old >/dev/null 2>&1
for t in 1.0 2.0; do docker ps -aq --filter ancestor=orders:$t 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1; done
docker image rm -f orders:1.0 orders:2.0 >/dev/null 2>&1
fresh_work
mkdir orders-src
cat > orders-src/server.js <<'JS'
const http = require("node:http");
const version = process.env.APP_VERSION;
const region = process.env.ORDERS_REGION || "none";
http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);
  res.end(`orders ${version} region=${region}\n`);
}).listen(3000, "0.0.0.0", () => console.log(`orders ${version} listening on 3000`));
JS
cat > orders-src/Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
ARG APP_VERSION=2.0
ENV APP_VERSION=$APP_VERSION
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
DF
echo "Building orders:1.0 and orders:2.0, starting the old containers..."
docker build -q --build-arg APP_VERSION=1.0 -t orders:1.0 orders-src >/dev/null || { echo "build failed"; exit 1; }
docker build -q -t orders:2.0 orders-src >/dev/null || { echo "build failed"; exit 1; }
# old v1 still serving on 8090
docker run -d --name orders-old -p 8090:3000 orders:1.0 >/dev/null
# a leftover, stopped container that grabbed the name "orders"
docker run -d --name orders orders:1.0 >/dev/null
docker stop -t 1 orders >/dev/null
banner "09-twist-port-taken (Twist): deploy orders:2.0 on port 8090"
