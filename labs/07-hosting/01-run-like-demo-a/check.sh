#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "app.env has LOG_LEVEL=info" 'grep -qx "LOG_LEVEL=info" app.env'
check "app.env has DATABASE_URL=postgres://app:s3cret@db.internal:5432/hello" 'grep -qx "DATABASE_URL=postgres://app:s3cret@db.internal:5432/hello" app.env'
check "image lab71-hello:1.0 exists" 'docker image inspect lab71-hello:1.0'
check "the image itself has no DATABASE_URL (secret not baked in)" 'docker image inspect lab71-hello:1.0 >/dev/null && ! docker image inspect lab71-hello:1.0 | grep -q DATABASE_URL'
check "container lab71-hello is running from lab71-hello:1.0" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" lab71-hello)" = "true lab71-hello:1.0" ]'
check "restart policy is unless-stopped" '[ "$(docker inspect -f "{{.HostConfig.RestartPolicy.Name}}" lab71-hello)" = unless-stopped ]'
check "port 3000 is published ONLY on 127.0.0.1:8301" '[ "$(docker port lab71-hello 3000/tcp)" = 127.0.0.1:8301 ]'
check "container has LOG_LEVEL and DATABASE_URL in its environment" 'e=$(docker inspect -f "{{json .Config.Env}}" lab71-hello); echo "$e" | grep -q "\"LOG_LEVEL=info\"" && echo "$e" | grep -q "\"DATABASE_URL=postgres://app:s3cret@db.internal:5432/hello\""'
check "GET 127.0.0.1:8301/ answers: hello-api log=info db=set" 'curl -s --max-time 3 http://127.0.0.1:8301/ | grep -qx "hello-api log=info db=set"'
summary
