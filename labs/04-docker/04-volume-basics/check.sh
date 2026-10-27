#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
need_docker
check "volume notes-data exists" 'docker volume inspect notes-data'
check "notes.txt in the volume has exactly: first note / second note" 'docker volume inspect notes-data >/dev/null && [ "$(docker run --rm -v notes-data:/data alpine:3.24 cat /data/notes.txt)" = "$(printf "first note\nsecond note")" ]'
check "no containers (running or stopped) left using notes-data" 'docker volume inspect notes-data >/dev/null && [ -z "$(docker ps -aq --filter volume=notes-data)" ]'
summary
