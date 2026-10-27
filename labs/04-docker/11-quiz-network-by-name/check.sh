#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
nets() { docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$1"; }
check "network lab11-net exists (bridge driver)" '[ "$(docker network inspect -f "{{.Driver}}" lab11-net)" = bridge ]'
check "lab11-api is running from lab11-api:1.0" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" lab11-api)" = "true lab11-api:1.0" ]'
check "lab11-api is attached to lab11-net" 'nets lab11-api | grep -qw lab11-net'
check "lab11-api publishes NO port to the host (internal only)" 'docker inspect lab11-api >/dev/null && [ -z "$(docker port lab11-api)" ]'
check "lab11-web is running from lab11-web:1.0" '[ "$(docker inspect -f "{{.State.Running}} {{.Config.Image}}" lab11-web)" = "true lab11-web:1.0" ]'
check "lab11-web is attached to lab11-net" 'nets lab11-web | grep -qw lab11-net'
check "lab11-web has API_URL=http://lab11-api:3000" 'docker inspect -f "{{json .Config.Env}}" lab11-web | grep -q "\"API_URL=http://lab11-api:3000\""'
check "lab11-web publishes 3000 on 127.0.0.1:8111" '[ "$(docker port lab11-web 3000/tcp)" = 127.0.0.1:8111 ]'
check "curl http://127.0.0.1:8111/ answers: web sees bolt stock=42" 'curl -s --max-time 4 http://127.0.0.1:8111/ | grep -qx "web sees bolt stock=42"'
apiip() { docker inspect -f '{{(index .NetworkSettings.Networks "lab11-net").IPAddress}}' lab11-api; }
check "answers.txt: api_ip= is the IP of lab11-api on lab11-net" 'ip=$(apiip); [ -n "$ip" ] && grep -qx "api_ip=$ip" answers.txt'
summary
