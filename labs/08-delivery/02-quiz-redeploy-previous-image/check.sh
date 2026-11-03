#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
STATE="$LAB_DIR/.lab-state"
GET="python3 $LAB_DIR/../_shop/http_get.py"
export STATE GET
echo "Checking..."
check "lab82-web is running" '[ "$(docker inspect -f "{{.State.Running}}" lab82-web)" = true ]'
check "lab82-web runs the image lab82-shop:2.3" '[ "$(docker inspect -f "{{.Config.Image}}" lab82-web)" = lab82-shop:2.3 ]'
check "lab82-web still publishes container port 3000 on host port 8402" 'docker port lab82-web 3000/tcp | grep -q ":8402$"'
check "lab82-web still has the env STORE=pune" 'docker inspect -f "{{range .Config.Env}}{{println .}}{{end}}" lab82-web | grep -qx "STORE=pune"'
check "http://127.0.0.1:8402/healthz says version 2.3, store pune" '$GET http://127.0.0.1:8402/healthz | grep -q "\"version\":\"2.3\",\"store\":\"pune\""'
check "kabir group order no longer fails (ok ... v2.3)" '$GET "http://127.0.0.1:8402/checkout?customer=kabir&group=1" | grep -q "^ok .*(v2.3)"'
check "no container from lab82-shop:2.4 is running" '[ -z "$(docker ps -q --filter ancestor=lab82-shop:2.4)" ]'
check "image lab82-shop:2.4 is kept (needed to investigate the bug)" '[ "$(docker image inspect -f "{{.Id}}" lab82-shop:2.4)" = "$(cat "$STATE/id-2.4")" ]'
check "no rebuild: lab82-shop:2.3 is the same image the pipeline built" '[ "$(docker image inspect -f "{{.Id}}" lab82-shop:2.3)" = "$(cat "$STATE/id-2.3")" ]'
summary
