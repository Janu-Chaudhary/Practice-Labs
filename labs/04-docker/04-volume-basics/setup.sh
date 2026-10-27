#!/usr/bin/env bash
# Drill: named volume + one-shot --rm containers (everything after the image is the command).
source "$(dirname "$0")/../../lib/common.sh"
need_docker
docker ps -aq --filter volume=notes-data | xargs -r docker rm -f >/dev/null 2>&1
docker volume rm -f notes-data >/dev/null 2>&1
fresh_work
docker image inspect alpine:3.24 >/dev/null 2>&1 || docker pull -q alpine:3.24 >/dev/null
banner "04-volume-basics (Drill): create notes-data and write two notes into it"
