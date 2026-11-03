#!/usr/bin/env bash
# Drill: run a service the way the T4L2 demo does (Step 3 + Step 5):
# detached, fixed name, restart policy, loopback-only port, config from an env file.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean only what this lab creates (lab71-* names)
docker rm -f lab71-hello >/dev/null 2>&1
docker ps -aq --filter ancestor=lab71-hello:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f lab71-hello:1.0 >/dev/null 2>&1
fresh_work
cat > server.js <<'JS'
const http = require("node:http");
// Config comes from the environment (Factor III). Missing config = refuse to start.
const { DATABASE_URL, LOG_LEVEL } = process.env;
if (!DATABASE_URL || !LOG_LEVEL) {
  console.error("FATAL: DATABASE_URL and LOG_LEVEL must be set");
  process.exit(1);
}
http.createServer((req, res) => {
  if (req.url === "/healthz") return res.end("ok\n");
  res.end(`hello-api log=${LOG_LEVEL} db=set\n`);
}).listen(3000, "0.0.0.0", () => console.log("hello-api listening on 3000"));
JS
cat > Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
DF
banner "01-run-like-demo-a (Drill): build, then docker run with --restart, 127.0.0.1 port and --env-file"
