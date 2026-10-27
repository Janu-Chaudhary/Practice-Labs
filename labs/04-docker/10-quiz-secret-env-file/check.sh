#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "Dockerfile no longer sets DB_PASSWORD (and still has COPY . .)" '! grep -q "DB_PASSWORD" Dockerfile && grep -qE "^COPY \. \.[[:space:]]*$" Dockerfile'
check ".dockerignore lists .env" '[ -f .dockerignore ] && grep -qE "^/?\.env[[:space:]]*$" .dockerignore'
check "image lab10-payments:1.1 exists" 'docker image inspect lab10-payments:1.1'
check "1.1: password not in the image config (docker image inspect)" 'docker image inspect lab10-payments:1.1 >/dev/null && ! docker image inspect lab10-payments:1.1 | grep -q Summer2024'
check "1.1: password not in any layer step (docker history)" 'docker image inspect lab10-payments:1.1 >/dev/null && ! docker history --no-trunc lab10-payments:1.1 | grep -q Summer2024'
check "1.1: no /app/.env file inside the image" 'docker image inspect lab10-payments:1.1 >/dev/null && docker run --rm lab10-payments:1.1 test ! -e /app/.env'
check "leaky tag lab10-payments:1.0 was removed" '! docker image inspect lab10-payments:1.0'
check "container lab10-payments is running from lab10-payments:1.1" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" lab10-payments)" = "true lab10-payments:1.1" ]'
check "lab10-payments publishes 3000 on 127.0.0.1:8110" '[ "$(docker port lab10-payments 3000/tcp)" = 127.0.0.1:8110 ]'
check "container got DB_HOST and DB_PASSWORD at run time (from .env)" 'e=$(docker inspect -f "{{json .Config.Env}}" lab10-payments); echo "$e" | grep -q "\"DB_HOST=db.internal\"" && echo "$e" | grep -q "\"DB_PASSWORD=Summer2024!\""'
check "curl http://127.0.0.1:8110/health answers: payments ok db=db.internal password=set" 'curl -s --max-time 3 http://127.0.0.1:8110/health | grep -qx "payments ok db=db.internal password=set"'
summary
