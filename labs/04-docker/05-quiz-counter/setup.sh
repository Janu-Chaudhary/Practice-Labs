#!/usr/bin/env bash
# Quiz-style: recreates Quiz 2 Q14 (build counter:1.0, volume counter-data, run -d -p 8080:3000 -v ...).
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker ps -aq --filter ancestor=counter:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker ps -aq --filter volume=counter-data 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f counter:1.0 >/dev/null 2>&1
docker volume rm -f counter-data >/dev/null 2>&1
fresh_work
cat > package.json <<'J'
{"name":"counter","version":"1.0.0","private":true,
 "scripts":{"start":"node server.js"}}
J
cat > package-lock.json <<'J'
{
  "name": "counter",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": { "name": "counter", "version": "1.0.0" }
  }
}
J
cat > server.js <<'JS'
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
printf 'node_modules\n.git\n.env\ndata\n' > .dockerignore
cat > Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
DF
docker image inspect node:24-alpine >/dev/null 2>&1 || docker pull -q node:24-alpine >/dev/null
if ss -ltn 2>/dev/null | grep -q ':8080 '; then
  echo "${Y}Note:${N} something already listens on port 8080. Free it first (docker ps; docker rm -f <name>)."
fi
banner "05-quiz-counter (Quiz-style, Quiz 2 Q14): build, volume, run"
