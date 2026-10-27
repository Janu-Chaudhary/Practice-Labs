#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir data
printf '%s\n' \
  'order_id,customer,status,amount' \
  '1001,asha,paid,250' \
  '1002,ben,unpaid,120' \
  '1003,asha,refunded,80' \
  '1004,chen,paid,40' \
  '1005,ben,paid,300' \
  '1006,asha,paid,15' \
  '1007,dev,unpaid,60' \
  '1008,chen,refunded,45' \
  '1009,asha,unpaid,99' \
  '1010,ben,paid,10' \
  > data/orders.csv
banner "11 CSV report (Twist): tail -n +2, cut -d, -f, sort -u, uniq -c | sort -rn | head, awk sum"
