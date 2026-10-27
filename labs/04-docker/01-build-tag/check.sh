#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "image hello-cli:1.0 exists" 'docker image inspect hello-cli:1.0'
check "hello-cli:1.0 was built from Dockerfile (no MODE=dev)" 'docker image inspect hello-cli:1.0 >/dev/null && ! docker image inspect -f "{{json .Config.Env}}" hello-cli:1.0 | grep -q MODE=dev'
check "image hello-cli:dev exists" 'docker image inspect hello-cli:dev'
check "hello-cli:dev was built from Dockerfile.dev (has MODE=dev)" 'docker image inspect -f "{{json .Config.Env}}" hello-cli:dev | grep -q MODE=dev'
check "no leftover containers from hello-cli (you used --rm)" 'docker image inspect hello-cli:1.0 hello-cli:dev >/dev/null && [ -z "$(docker ps -aq --filter ancestor=hello-cli:1.0)" ] && [ -z "$(docker ps -aq --filter ancestor=hello-cli:dev)" ]'
summary
