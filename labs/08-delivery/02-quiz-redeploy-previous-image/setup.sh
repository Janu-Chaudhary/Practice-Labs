#!/usr/bin/env bash
# Quiz-style: v2.4 is live and 1 in 5 checkouts fail. Roll back by redeploying the previous image
# (lab82-shop:2.3) under the same name, port and env. No rebuild, keep the 2.4 image.
source "$(dirname "$0")/../../lib/common.sh"
need_docker
SHOP="$LAB_DIR/../_shop"
STATE="$LAB_DIR/.lab-state"
# clean only what this lab creates (lab82-*)
docker rm -f lab82-web >/dev/null 2>&1
docker ps -a --format '{{.ID}} {{.Image}}' | awk '$2 ~ /^lab82-shop/ {print $1}' | xargs -r docker rm -f >/dev/null 2>&1
docker image ls -q lab82-shop 2>/dev/null | sort -u | xargs -r docker image rm -f >/dev/null 2>&1
rm -rf "$STATE"; mkdir -p "$STATE"
fresh_work
mkdir app
cp "$SHOP/server.js" "$SHOP/Dockerfile" app/
echo "Building lab82-shop:2.3 and lab82-shop:2.4 (the pipeline did this earlier)..."
docker build -q --build-arg RELEASE=2.3 -t lab82-shop:2.3 app >/dev/null || { echo "build failed"; exit 1; }
docker build -q --build-arg RELEASE=2.4 -t lab82-shop:2.4 app >/dev/null || { echo "build failed"; exit 1; }
docker image inspect -f '{{.Id}}' lab82-shop:2.3 > "$STATE/id-2.3"
docker image inspect -f '{{.Id}}' lab82-shop:2.4 > "$STATE/id-2.4"
# the deploy of 2.4 (Friday 19:00)
docker run -d --name lab82-web -p 127.0.0.1:8402:3000 -e STORE=pune lab82-shop:2.4 >/dev/null
for i in $(seq 1 40); do docker exec lab82-web wget -qO- http://localhost:3000/healthz >/dev/null 2>&1 && break; sleep 0.25; done
# some customer traffic: every 5th order is kabir's group order
for c in ravi meena zoya asha; do
  docker exec lab82-web wget -qO- "http://localhost:3000/checkout?customer=$c" >/dev/null 2>&1
done
docker exec lab82-web wget -qO- "http://localhost:3000/checkout?customer=kabir&group=1" >/dev/null 2>&1
docker exec lab82-web wget -qO- "http://localhost:3000/checkout?customer=asha&group=1" >/dev/null 2>&1
docker exec lab82-web wget -qO- "http://localhost:3000/checkout?customer=kabir&group=1" >/dev/null 2>&1
banner "02-quiz-redeploy-previous-image (Quiz-style): checkout is failing on 2.4. Roll back to 2.3"
