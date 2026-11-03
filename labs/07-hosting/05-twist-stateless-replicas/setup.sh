#!/usr/bin/env bash
# Twist: two replicas behind a load balancer give inconsistent answers because the state lives in
# each process's memory. Move the state out (a shared named volume), redeploy both replicas.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean only what this lab creates (lab75-* names)
docker rm -f lab75-lb lab75-web-1 lab75-web-2 >/dev/null 2>&1
for t in 1.0 1.1; do docker ps -aq --filter ancestor=lab75-web:$t 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1; done
docker image rm -f lab75-web:1.0 lab75-web:1.1 >/dev/null 2>&1
docker volume rm -f lab75-data >/dev/null 2>&1
docker network rm lab75-net >/dev/null 2>&1
fresh_work
mkdir -p lb
cat > server.js <<'JS'
const http = require("node:http");
const os = require("node:os");

let visits = 0; // the visit counter lives IN MEMORY of this one process

http.createServer((req, res) => {
  if (req.url === "/healthz") return res.end("ok\n");
  if (req.url !== "/") { res.statusCode = 404; return res.end("not found\n"); }
  visits += 1;
  res.end(`visits=${visits} served-by=${os.hostname()}\n`);
}).listen(3000, "0.0.0.0", () => console.log("web listening on 3000"));
JS
cat > Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
DF
cat > lb/nginx.conf <<'CONF'
# Load balancer: round-robin over the two replicas, found by container name on lab75-net.
# nginx looks the names up ONCE, when it starts.
events {}
http {
  upstream web {
    server lab75-web-1:3000;
    server lab75-web-2:3000;
  }
  server {
    listen 80;
    location / {
      proxy_pass http://web;
      proxy_connect_timeout 2s;
    }
  }
}
CONF
echo "Building lab75-web:1.0 and starting 2 replicas + load balancer ..."
docker build -q -t lab75-web:1.0 . >/dev/null || { echo "build failed"; exit 1; }
docker network create lab75-net >/dev/null
docker run -d --name lab75-web-1 --network lab75-net lab75-web:1.0 >/dev/null
docker run -d --name lab75-web-2 --network lab75-net lab75-web:1.0 >/dev/null
docker run -d --name lab75-lb --network lab75-net -p 127.0.0.1:8350:80 \
  -v "$WORK/lb/nginx.conf:/etc/nginx/nginx.conf:ro" nginx:alpine >/dev/null
banner "05-twist-stateless-replicas (Twist): move in-memory state out so 2 replicas agree"
