#!/usr/bin/env bash
# Twist: a container exits right after start. Read ps -a / logs / inspect ExitCode, then fix it with a
# read-only bind mount of a host config folder; edit the file on the host and restart (no rebuild).
source "$(dirname "$0")/../../lib/common.sh"
need_docker
# clean what this lab creates (only lab12-* names)
docker rm -f lab12-report >/dev/null 2>&1
docker ps -aq --filter ancestor=lab12-report:1.0 2>/dev/null | xargs -r docker rm -f >/dev/null 2>&1
docker image rm -f lab12-report:1.0 >/dev/null 2>&1
fresh_work
mkdir report-src config
cat > report-src/server.js <<'JS'
const http = require("node:http");
const fs = require("node:fs");
const FILE = "/config/settings.json";
let raw, cfg;
try { raw = fs.readFileSync(FILE, "utf8"); }
catch (e) {
  console.error(`FATAL: cannot read ${FILE} (${e.code}). Mount your config folder at /config.`);
  process.exit(3);
}
try { cfg = JSON.parse(raw); }
catch (e) {
  console.error(`FATAL: ${FILE} is not valid JSON: ${e.message}`);
  process.exit(4);
}
if (!cfg.title) { console.error(`FATAL: ${FILE} has no "title"`); process.exit(5); }
console.log(`report service: title="${cfg.title}" listening on 3000`);
http.createServer((req, res) => res.end(`report: ${cfg.title}\n`))
  .listen(3000, "0.0.0.0");
JS
cat > report-src/Dockerfile <<'DF'
FROM node:24-alpine
WORKDIR /app
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
DF
# the config the ops team wrote by hand (note: it has a mistake)
cat > config/settings.json <<'J'
{
  "title": "Daily report",
  "owner": "ops",
}
J
docker image inspect node:24-alpine >/dev/null 2>&1 || docker pull -q node:24-alpine >/dev/null
echo "Building lab12-report:1.0 and starting container lab12-report..."
docker build -q -t lab12-report:1.0 report-src >/dev/null || { echo "build failed"; exit 1; }
docker run -d --name lab12-report -p 127.0.0.1:8112:3000 lab12-report:1.0 >/dev/null
printf 'first_exit_code=\n' > answers.txt
sleep 1
banner "12-twist-crash-bind-config (Twist): lab12-report keeps dying. Find out why and fix it"
