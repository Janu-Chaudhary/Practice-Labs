#!/usr/bin/env bash
# Quiz-style: the fastest way back. group_order (100%) crashes kabir's orders: switch the flag off in
# flags.json (read on every request) and raise new_menu to 50%, WITHOUT restarting or redeploying.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
SHOP="$LAB_DIR/../_shop"
STATE="$LAB_DIR/.lab-state"
# clean only what this lab creates (lab84-*)
docker rm -f lab84-web >/dev/null 2>&1
docker ps -a --format '{{.ID}} {{.Image}}' | awk '$2 ~ /^lab84-shop/ {print $1}' | xargs -r docker rm -f >/dev/null 2>&1
docker image ls -q lab84-shop 2>/dev/null | sort -u | xargs -r docker image rm -f >/dev/null 2>&1
rm -rf "$STATE"; mkdir -p "$STATE"
fresh_work
mkdir app flags
cp "$SHOP/server.js" "$SHOP/Dockerfile" app/
cat > flags/flags.json <<'J'
{
  "group_order": { "rollout_percent": 100 },
  "new_menu": { "rollout_percent": 10 }
}
J
echo "Building lab84-shop:2.5 and starting lab84-web..."
docker build -q --build-arg RELEASE=2.5 -t lab84-shop:2.5 app >/dev/null || { echo "build failed"; exit 1; }
docker run -d --name lab84-web -p 127.0.0.1:8404:3000 -v "$WORK/flags":/flags:ro lab84-shop:2.5 >/dev/null
for i in $(seq 1 40); do docker exec lab84-web wget -qO- http://localhost:3000/healthz >/dev/null 2>&1 && break; sleep 0.25; done
docker inspect -f '{{.Id}}' lab84-web > "$STATE/cid"
docker inspect -f '{{.State.StartedAt}}' lab84-web > "$STATE/started"
docker image inspect -f '{{.Id}}' lab84-shop:2.5 > "$STATE/img"
for c in ravi meena zoya asha; do
  docker exec lab84-web wget -qO- "http://localhost:3000/checkout?customer=$c" >/dev/null 2>&1
done
docker exec lab84-web wget -qO- "http://localhost:3000/checkout?customer=asha&group=1" >/dev/null 2>&1
docker exec lab84-web wget -qO- "http://localhost:3000/checkout?customer=kabir&group=1" >/dev/null 2>&1
docker exec lab84-web wget -qO- "http://localhost:3000/checkout?customer=zoya&group=1" >/dev/null 2>&1
banner "04-quiz-kill-switch (Quiz-style): group orders are crashing. Switch the flag off, no redeploy"
