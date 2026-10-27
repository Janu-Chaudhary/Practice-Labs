#!/usr/bin/env bash
# Drill: read a running container with ps, port, logs, exec, top, inspect.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker rm -f notes-api >/dev/null 2>&1
docker image rm -f notes-api:1.0 >/dev/null 2>&1
fresh_work
mkdir notes-src
cat > notes-src/server.js <<'JS'
const http = require("node:http");
const crypto = require("node:crypto");
const token = crypto.randomBytes(4).toString("hex");
console.log(`startup token: ${token}`);
http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);
  res.end("notes-api ok\n");
}).listen(3000, "0.0.0.0", () => console.log("notes-api listening on 3000"));
JS
cat > notes-src/Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
DF
echo "Building and starting notes-api..."
docker build -q -t notes-api:1.0 notes-src >/dev/null || { echo "build failed"; exit 1; }
# 127.0.0.1::3000 = let Docker pick a free host port
docker run -d --name notes-api -p 127.0.0.1::3000 notes-api:1.0 >/dev/null
words=(falcon cobalt maple quartz ember lotus)
motd="${words[RANDOM % ${#words[@]}]}-$RANDOM"
sleep 1
docker exec notes-api sh -c "echo $motd > /tmp/motd.txt"
printf 'port=\ntoken=\nmotd=\nhostpid=\n' > answers.txt
banner "03-inspect-running (Drill): fill work/answers.txt about container notes-api"
