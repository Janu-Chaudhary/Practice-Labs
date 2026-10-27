#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
NOTES=("Meeting notes" "- decide on folder layout")
DRAFT=("First draft of the design doc")
CONF=("port: 8080" "debug: false")

check "project/src/utils is a folder"                 '[ -d project/src/utils ]'
check "project/src/utils/__init__.py exists and is empty" '[ -f project/src/utils/__init__.py ] && [ ! -s project/src/utils/__init__.py ]'
check "README.md has the notes contents"              'same README.md "${NOTES[@]}"'
check "notes.txt is gone"                             '[ ! -e notes.txt ]'
check "docs is a folder (not a file called docs)"     '[ -d docs ]'
check "docs/draft.txt has the draft contents"         'same docs/draft.txt "${DRAFT[@]}"'
check "draft.txt is gone from the top folder"         '[ ! -e draft.txt ]'
check "config.yml is still there, unchanged"          'same config.yml "${CONF[@]}"'
check "config.yml.bak is an identical copy"           'same config.yml.bak "${CONF[@]}"'
check "tmp folder is gone"                            '[ ! -e tmp ]'
summary
