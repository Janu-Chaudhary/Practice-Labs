#!/usr/bin/env bash
# Fake customers checking out, 3 per second. Every 5th one is a group order
# from kabir, who has no saved group. Run it in a second terminal; Ctrl-C stops it.
cd "$(dirname "$0")" || exit 1
source ../lib/demo-lib.sh

CUSTOMERS="asha ravi meena zoya"
i=0
echo "TiffinGo checkouts via http://localhost:8080   (Ctrl-C to stop)"
while true; do
  i=$((i + 1))
  if [ $((i % 5)) -eq 0 ]; then
    q="customer=kabir&group=1"
  else
    set -- $CUSTOMERS; shift $(( i % 4 )); q="customer=${1:-asha}&group=0"
  fi
  body=$(curl -s -m 3 "http://localhost:8080/checkout?$q")
  t=$(date +%H:%M:%S)
  case "$body" in
    ok*)    echo "$t  ${G}$body${N}" ;;
    ERROR*) echo "$t  ${R}$body${N}" ;;
    "")     echo "$t  ${Y}no answer${N}" ;;
    *)      echo "$t  ${Y}$body${N}" ;;
  esac
  sleep 0.3
done
