#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
# norm FILE: squeeze spaces/tabs, drop leading/trailing ones (uniq -c pads counts with spaces)
norm() { sed -e 's/[[:space:]]\+/ /g' -e 's/^ //' -e 's/ $//' "$1"; }
CSV=(
  'order_id,customer,status,amount'
  '1001,asha,paid,250'
  '1002,ben,unpaid,120'
  '1003,asha,refunded,80'
  '1004,chen,paid,40'
  '1005,ben,paid,300'
  '1006,asha,paid,15'
  '1007,dev,unpaid,60'
  '1008,chen,refunded,45'
  '1009,asha,unpaid,99'
  '1010,ben,paid,10'
)
RP="$WORK/reports"

check "reports/customers.txt = asha ben chen dev (once each, A-Z, no header)" 'same reports/customers.txt asha ben chen dev'
[ -f "$RP/customers.txt" ] && grep -qx customer "$RP/customers.txt" && hint "the header word 'customer' got in: skip line 1 with tail -n +2"
check "reports/refunded-ids.txt = 1003 then 1008"                           'same reports/refunded-ids.txt 1003 1008'
[ -f "$RP/refunded-ids.txt" ] && grep -q ',' "$RP/refunded-ids.txt" && hint "whole lines saved: keep only field 1 with cut -d, -f1"
check "reports/paid-total.txt holds just 615"                                '[ "$(tr -d " \t\n" < reports/paid-total.txt)" = 615 ]'
[ -f "$RP/paid-total.txt" ] && [ "$(tr -d ' \t\n' < "$RP/paid-total.txt")" = 894 ] && hint "894 includes the 'unpaid' orders: 'paid' is inside 'unpaid'. Match the whole field"
check "reports/top2.txt = '4 asha' then '3 ben'"                             '[ "$(norm reports/top2.txt)" = "$(printf "%s\n" "4 asha" "3 ben")" ]'
check "data/orders.csv is unchanged"                                         'same data/orders.csv "${CSV[@]}"'
summary
