#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
printf '%s\n' "Meeting notes" "- decide on folder layout" > notes.txt
printf '%s\n' "First draft of the design doc" > draft.txt
printf '%s\n' "port: 8080" "debug: false" > config.yml
mkdir -p tmp/cache
printf 'junk\n' > tmp/cache1.bin
printf 'junk\n' > tmp/cache/cache2.bin
banner "01 files and folders (Drill): mkdir -p, touch, mv, cp, rm -r"
