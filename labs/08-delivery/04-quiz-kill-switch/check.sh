#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
STATE="$LAB_DIR/.lab-state"
GET="python3 $LAB_DIR/../_shop/http_get.py"
export STATE GET
pj() { python3 -c "import json,sys; d=json.load(open('flags/flags.json')); sys.exit(0 if ($1) else 1)"; }
export -f pj
echo "Checking..."
check "flags/flags.json is still valid JSON" 'pj True'
check "group_order.rollout_percent is 0 (kill switch)" 'pj "d[\"group_order\"][\"rollout_percent\"] == 0"'
check "new_menu.rollout_percent is 50" 'pj "d[\"new_menu\"][\"rollout_percent\"] == 50"'
check "no flags added or removed (exactly group_order and new_menu)" 'pj "sorted(d) == [\"group_order\", \"new_menu\"]"'
check "lab84-web is the SAME container as before (not removed and re-created)" '[ "$(docker inspect -f "{{.Id}}" lab84-web)" = "$(cat "$STATE/cid")" ]'
check "lab84-web was not restarted (same StartedAt) and is running" '[ "$(docker inspect -f "{{.State.StartedAt}} {{.State.Running}}" lab84-web)" = "$(cat "$STATE/started") true" ]'
check "no new image: lab84-shop:2.5 is unchanged, no other lab84-shop tags" '[ "$(docker image inspect -f "{{.Id}}" lab84-shop:2.5)" = "$(cat "$STATE/img")" ] && [ "$(docker image ls lab84-shop --format "{{.Tag}}")" = 2.5 ]'
check "kabir group order now answers ok ... single (v2.5)" '$GET "http://127.0.0.1:8404/checkout?customer=kabir&group=1" | grep -q "^ok .* single  (v2.5)"'
check "the app sees new_menu at 50 (meena is ON)" '$GET "http://127.0.0.1:8404/flag?name=new_menu&user=meena" | grep -q "rollout_percent 50 -> ON"'
summary
