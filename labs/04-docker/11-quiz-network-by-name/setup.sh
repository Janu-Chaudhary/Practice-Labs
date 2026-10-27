#!/usr/bin/env bash
# Quiz-style (harder): two containers talk over a user-defined network by container name.
# The broken start: web uses localhost to reach api, both on the default bridge, api published to the host.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean what this lab creates (only lab11-* names)
docker rm -f lab11-api lab11-web >/dev/null 2>&1
for i in lab11-api:1.0 lab11-web:1.0; do docker ps -aq --filter ancestor=$i 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1; done
docker network rm lab11-net >/dev/null 2>&1
docker image rm -f lab11-api:1.0 lab11-web:1.0 >/dev/null 2>&1
fresh_work
mkdir api-src web-src
cat > api-src/server.js <<'JS'
const http = require("node:http");
http.createServer((req, res) => {
  console.log(`api: ${req.method} ${req.url}`);
  if (req.url === "/stock") return res.end(JSON.stringify({ item: "bolt", stock: 42 }) + "\n");
  res.end("stock-api\n");
}).listen(3000, "0.0.0.0", () => console.log("stock-api listening on 3000"));
JS
cat > web-src/server.js <<'JS'
const http = require("node:http");
const API_URL = process.env.API_URL || "http://localhost:3000";
http.createServer(async (req, res) => {
  try {
    const r = await fetch(`${API_URL}/stock`, { signal: AbortSignal.timeout(2000) });
    const data = await r.json();
    res.end(`web sees ${data.item} stock=${data.stock}\n`);
  } catch (e) {
    const why = (e.cause && (e.cause.code || e.cause.message)) || e.message;
    console.error(`web: cannot reach ${API_URL}/stock: ${why}`);
    res.statusCode = 502;
    res.end(`502 web cannot reach API_URL=${API_URL} (${why})\n`);
  }
}).listen(3000, "0.0.0.0", () => console.log(`web listening on 3000, API_URL=${API_URL}`));
JS
for s in api web; do cat > $s-src/Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
DF
done
docker image inspect node:24-alpine >/dev/null 2>&1 || docker pull -q node:24-alpine >/dev/null
echo "Building lab11-api:1.0 and lab11-web:1.0, starting the (broken) setup..."
docker build -q -t lab11-api:1.0 api-src >/dev/null || { echo "build failed"; exit 1; }
docker build -q -t lab11-web:1.0 web-src >/dev/null || { echo "build failed"; exit 1; }
# the teammate's attempt: api published on the host, web told to use localhost
docker run -d --name lab11-api -p 127.0.0.1:8119:3000 lab11-api:1.0 >/dev/null
docker run -d --name lab11-web -p 127.0.0.1:8111:3000 -e API_URL=http://localhost:8119 lab11-web:1.0 >/dev/null
printf 'api_ip=\n' > answers.txt
banner "11-quiz-network-by-name (Quiz-style): make lab11-web reach lab11-api by name on lab11-net"
