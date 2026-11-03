#!/usr/bin/env bash
# Switch the group_order flag: ./flag.sh on   or   ./flag.sh off
# No deploy. v2.5 reads the flag from the database on every request.
cd "$(dirname "$0")" || exit 1
source ./t5-lib.sh

case "${1:-}" in
  on)  v=true ;;
  off) v=false ;;
  *)   echo "usage: ./flag.sh on|off"; exit 1 ;;
esac
show "UPDATE flags SET enabled = $v WHERE name = 'group_order';"
psql_db -c "UPDATE flags SET enabled = $v WHERE name = 'group_order';" || exit 1
ok "group_order is now $(echo "$1" | tr a-z A-Z). No deploy. The next request sees it."
