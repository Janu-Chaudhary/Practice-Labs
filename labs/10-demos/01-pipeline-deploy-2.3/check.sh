#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
source "$LAB_DIR/../_t5.sh"
need_docker
echo "Checking..."
check "the platform is up: t5-db and t5-proxy are running" \
  '[ "$(docker inspect -f "{{.State.Running}}" t5-db)" = true ] && [ "$(docker inspect -f "{{.State.Running}}" t5-proxy)" = true ]'
check "http://localhost:8080/healthz says version 2.3" 'hz | grep -q "\"version\":\"2.3\""'
check "exactly one app container runs, from image tiffingo:2.3" \
  '[ "$(running_app | wc -l)" -eq 1 ] && running_app | grep -q " tiffingo:2.3$"'
check "build once, two tags: tiffingo:2.3 has a second tag (the code id) with the same IMAGE ID" \
  'id=$(docker image inspect -f "{{.Id}}" tiffingo:2.3) && [ "$(docker images tiffingo --no-trunc --format "{{.ID}}" | grep -c "$id")" -ge 2 ]'
check "the 2.3 migration is recorded in schema_migrations" '[ "$(sql "SELECT version FROM schema_migrations")" = 2.3 ]'
check "a checkout through the load balancer answers ok (v2.3)" 'co "customer=asha&group=0" | grep -q "^ok .*(v2.3)"'
check "traffic.log exists and shows ok checkouts on v2.3 (./traffic.sh > traffic.log 2>&1 &)" \
  '[ "$(grep -c "ok .*(v2.3)" traffic.log)" -ge 3 ]'
summary
