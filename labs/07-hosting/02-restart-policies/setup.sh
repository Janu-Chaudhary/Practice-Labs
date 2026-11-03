#!/usr/bin/env bash
# Drill: restart policies. Change one in place (docker update), watch a crash get undone,
# pick on-failure for a one-off job, and see that docker stop is NOT undone.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean only what this lab creates (lab72-* names)
docker rm -f lab72-api lab72-migrate lab72-legacy >/dev/null 2>&1
for i in lab72-api:1.0 lab72-jobs:1.0; do docker ps -aq --filter ancestor=$i 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1; done
docker volume rm -f lab72-state >/dev/null 2>&1
docker image rm -f lab72-api:1.0 lab72-jobs:1.0 >/dev/null 2>&1
fresh_work
mkdir -p api jobs
cat > api/server.js <<'JS'
const http = require("node:http");
http.createServer((req, res) => res.end("api ok\n"))
  .listen(3000, "0.0.0.0", () => console.log(new Date().toISOString(), "api started"));
JS
cat > api/Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
DF
cat > jobs/migrate.sh <<'SH'
#!/bin/sh
# One-off job: apply DB migrations, then exit. The DB is "not ready" on the first 2 tries.
n=$(cat /state/attempts 2>/dev/null || echo 0); n=$((n+1)); echo "$n" > /state/attempts
if [ -f /state/done ]; then echo "attempt $n: already up to date, nothing to do"; exit 0; fi
if [ "$n" -lt 3 ]; then echo "attempt $n: database not ready yet"; exit 1; fi
touch /state/done
echo "attempt $n: applied 3 migrations"
exit 0
SH
cat > jobs/Dockerfile <<'DF'
FROM alpine:3.24
COPY migrate.sh /migrate.sh
RUN chmod +x /migrate.sh
CMD ["/migrate.sh"]
DF
echo "Building lab72-api:1.0 and lab72-jobs:1.0 ..."
docker build -q -t lab72-api:1.0 api >/dev/null || { echo "build failed"; exit 1; }
docker build -q -t lab72-jobs:1.0 jobs >/dev/null || { echo "build failed"; exit 1; }
# --init: a tiny init is PID 1 and node is its child, so "pkill -9 node" really kills the app
# (like the demo's sudo pkill -9 on the VM). The teammate forgot the restart policy.
docker run -d --init --name lab72-api -p 127.0.0.1:8302:3000 lab72-api:1.0 >/dev/null
docker run -d --init --name lab72-legacy --restart always alpine:3.24 sleep 100000 >/dev/null
banner "02-restart-policies (Drill): docker update --restart, crash recovery, on-failure, docker stop"
