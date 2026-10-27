#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "container orders is running from orders:2.0" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" orders)" = "true orders:2.0" ]'
check "orders publishes host 8090 -> 3000" 'docker port orders 3000/tcp | grep -q ":8090$"'
check "orders has ORDERS_REGION=eu" 'docker inspect -f "{{json .Config.Env}}" orders | grep -q "\"ORDERS_REGION=eu\""'
check "orders-old still exists (not removed) from orders:1.0" '[ "$(docker inspect -f "{{.Config.Image}}" orders-old)" = orders:1.0 ]'
check "orders-old is stopped" '[ "$(docker inspect -f "{{.State.Running}}" orders-old)" = false ]'
check "curl http://localhost:8090/ answers: orders 2.0 region=eu" 'curl -s --max-time 3 http://localhost:8090/ | grep -qx "orders 2.0 region=eu"'
summary
