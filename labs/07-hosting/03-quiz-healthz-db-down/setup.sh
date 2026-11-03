#!/usr/bin/env bash
# Quiz-style: /healthz (liveness) must not touch the DB; /readyz does. Add a Dockerfile HEALTHCHECK
# and prove the container stays "healthy" while the database is down.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean only what this lab creates (lab73-* names)
docker rm -f lab73-api lab73-db >/dev/null 2>&1
for t in 1.0 1.1; do docker ps -aq --filter ancestor=lab73-api:$t 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1; done
docker image rm -f lab73-api:1.0 lab73-api:1.1 >/dev/null 2>&1
docker network rm lab73-net >/dev/null 2>&1
fresh_work
cat > server.js <<'JS'
const http = require("node:http");
const net = require("node:net");
const DB_HOST = process.env.DB_HOST;
const DB_PORT = Number(process.env.DB_PORT || 5432);
if (!DB_HOST) { console.error("FATAL: DB_HOST must be set"); process.exit(1); }

// Can we open a TCP connection to the database right now? (1 second timeout)
function checkDb(cb) {
  let done = false;
  const finish = (ok) => { if (!done) { done = true; sock.destroy(); cb(ok); } };
  const sock = net.connect({ host: DB_HOST, port: DB_PORT });
  sock.setTimeout(1000);
  sock.on("connect", () => finish(true));
  sock.on("error", () => finish(false));
  sock.on("timeout", () => finish(false));
}

http.createServer((req, res) => {
  if (req.url === "/healthz") {
    checkDb((ok) => {
      res.statusCode = ok ? 200 : 503;
      res.end(ok ? "ok\n" : "db down\n");
    });
    return;
  }
  if (req.url === "/hello") {
    checkDb((ok) => {
      res.statusCode = ok ? 200 : 503;
      res.end(ok ? "hello from lab73-api\n" : "db down\n");
    });
    return;
  }
  res.statusCode = 404;
  res.end("not found\n");
}).listen(3000, "0.0.0.0", () => console.log(`lab73-api listening on 3000 (db=${DB_HOST}:${DB_PORT})`));
JS
cat > Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
DF
printf 'DB_HOST=lab73-db\nDB_PORT=5432\n' > app.env
docker network create lab73-net >/dev/null
docker run -d --name lab73-db --network lab73-net -e POSTGRES_PASSWORD=dev postgres:16-alpine >/dev/null
banner "03-quiz-healthz-db-down (Quiz-style): liveness without the DB, HEALTHCHECK, healthy while the DB is down"
