#!/usr/bin/env bash
# Quiz-style: stop/start vs rm, named volume via --mount, resource limits (--cpus, --memory).
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker rm -f tally-web >/dev/null 2>&1
docker ps -aq --filter volume=tally-data 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker ps -aq --filter ancestor=tally:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f tally:1.0 >/dev/null 2>&1
docker volume rm -f tally-data >/dev/null 2>&1
fresh_work
mkdir tally-src
cat > tally-src/server.js <<'JS'
const http = require("node:http");
const fs = require("node:fs");
const file = "/data/count.txt";
http.createServer((req, res) => {
  if (req.url === "/health") return res.end("ok\n");
  fs.mkdirSync("/data", { recursive: true });
  const n = Number(fs.existsSync(file) ? fs.readFileSync(file, "utf8") : 0) + 1;
  fs.writeFileSync(file, String(n));
  console.log(`request count=${n}`);
  res.end(`count=${n}\n`);
}).listen(3000, "0.0.0.0", () => console.log("listening on 3000"));
JS
cat > tally-src/Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
DF
echo "Building tally:1.0 for you..."
docker build -q -t tally:1.0 tally-src >/dev/null || { echo "build failed"; exit 1; }
printf 'no_volume_count=\n' > answers.txt
banner "07-quiz-survives-rm (Quiz-style): what survives stop/start and rm?"
