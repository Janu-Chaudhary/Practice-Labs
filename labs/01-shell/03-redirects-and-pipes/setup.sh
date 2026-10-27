#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
printf '%s\n' maya liam zoe maya arjun liam maya ben > visitors.txt
banner "03 redirects and pipes (Drill): new file in the editor, >, |, sort, uniq, wc -l, head"
