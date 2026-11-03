#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "Dockerfile has a HEALTHCHECK that calls /healthz" 'grep -qE "^HEALTHCHECK .*CMD .*/healthz" Dockerfile'
check "app.env unchanged (DB_HOST=lab73-db)" 'grep -qx "DB_HOST=lab73-db" app.env'
check "image lab73-api:1.1 exists and has a healthcheck" 'docker image inspect -f "{{json .Config.Healthcheck}}" lab73-api:1.1 | grep -q healthz'
check "container lab73-api runs lab73-api:1.1 on network lab73-net" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" lab73-api)" = "true lab73-api:1.1" ] && docker inspect -f "{{json .NetworkSettings.Networks}}" lab73-api | grep -q "\"lab73-net\""'
check "lab73-api publishes 3000 on 127.0.0.1:8303" '[ "$(docker port lab73-api 3000/tcp)" = 127.0.0.1:8303 ]'
check "lab73-api got DB_HOST=lab73-db at run time" 'docker inspect -f "{{json .Config.Env}}" lab73-api | grep -q "\"DB_HOST=lab73-db\""'
check "the database lab73-db is down (stopped, not removed)" '[ "$(docker inspect -f "{{.State.Status}}" lab73-db)" = exited ]'
check "with the DB down: GET /healthz -> 200 ok" '[ "$(curl -s -o /tmp/lab73-h.$$ -w "%{http_code}" --max-time 4 http://127.0.0.1:8303/healthz)" = 200 ] && grep -qx ok /tmp/lab73-h.$$; r=$?; rm -f /tmp/lab73-h.$$; exit $r'
check "with the DB down: GET /readyz -> 503 (not ready)" '[ "$(curl -s -o /dev/null -w "%{http_code}" --max-time 4 http://127.0.0.1:8303/readyz)" = 503 ]'
check "with the DB down: GET /hello -> 503" '[ "$(curl -s -o /dev/null -w "%{http_code}" --max-time 4 http://127.0.0.1:8303/hello)" = 503 ]'
check "docker says lab73-api is healthy (while the DB is down)" '[ "$(docker inspect -f "{{.State.Health.Status}}" lab73-api)" = healthy ]'
summary
