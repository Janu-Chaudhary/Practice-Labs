#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "container greeter-web is running" '[ "$(docker inspect -f "{{.State.Running}}" greeter-web)" = true ]'
check "greeter-web runs image greeter:1.0" '[ "$(docker inspect -f "{{.Config.Image}}" greeter-web)" = greeter:1.0 ]'
check "port 3000 published on 127.0.0.1:8081 only" '[ "$(docker port greeter-web 3000/tcp)" = 127.0.0.1:8081 ]'
check "env GREETING=Hola is set" 'docker inspect -f "{{json .Config.Env}}" greeter-web | grep -q "\"GREETING=Hola\""'
check "curl http://127.0.0.1:8081/ answers Hola from greeter" 'curl -s --max-time 3 http://127.0.0.1:8081/ | grep -q "Hola from greeter"'
summary
