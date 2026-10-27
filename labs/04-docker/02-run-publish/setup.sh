#!/usr/bin/env bash
# Drill: docker run -d --name -p 127.0.0.1:HOST:CONTAINER -e ... image:tag
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker rm -f greeter-web >/dev/null 2>&1
docker ps -aq --filter ancestor=greeter:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f greeter:1.0 >/dev/null 2>&1
fresh_work
mkdir greeter-src
cat > greeter-src/server.js <<'JS'
const http = require("node:http");
const greeting = process.env.GREETING || "Hello";
http.createServer((req, res) => {
  if (req.url === "/health") return res.end("ok\n");
  res.end(`${greeting} from greeter\n`);
}).listen(3000, "0.0.0.0", () => console.log("greeter listening on 3000"));
JS
cat > greeter-src/Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
DF
echo "Building greeter:1.0 for you (first time may pull node:24-alpine)..."
docker build -q -t greeter:1.0 greeter-src >/dev/null || { echo "build failed"; exit 1; }
banner "02-run-publish (Drill): run greeter:1.0 as greeter-web on 127.0.0.1:8081"
