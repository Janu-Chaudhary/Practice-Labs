#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
same() { cmp -s "$1" <(printf '%s\n' "${@:2}"); }
TODAY="$(date +%F)"
OK=("OK    orders" "OK    users" "OK    health")
ERR=("ERROR payments is down" "ERROR search is down")
ALL=("OK    orders" "ERROR payments is down" "OK    users" "ERROR search is down" "OK    health")
RP="$WORK/reports"

check "bin/healthcheck.sh is executable"                        '[ -x bin/healthcheck.sh ]'
script_text() { cat <<'SCRIPT'
#!/usr/bin/env bash
# Checks every service listed in config/services.conf (run it from the folder that holds config/).
# Healthy services are printed on stdout, problems on stderr.
# Exit code: 0 if every service is up, 1 if any is down.
status=0
while IFS='=' read -r name state; do
  if [ "$state" = "up" ]; then
    echo "OK    $name"
  else
    echo "ERROR $name is $state" >&2
    status=1
  fi
done < config/services.conf
exit $status
SCRIPT
}
check "bin/healthcheck.sh content unchanged"                    'cmp -s bin/healthcheck.sh <(script_text)'
check "config/services.conf unchanged"                          'same config/services.conf orders=up payments=down users=up search=down health=up'
check "reports/ok.txt = only the 3 OK lines (stdout)"           'same reports/ok.txt "${OK[@]}"'
[ -f "$RP/ok.txt" ] && grep -q ERROR "$RP/ok.txt" && hint "ERROR lines are in ok.txt: send stderr (2>) to its own file"
check "reports/errors.txt = only the 2 ERROR lines (stderr)"    'same reports/errors.txt "${ERR[@]}"'
check "reports/all.txt = all 5 lines, in the order printed"     'same reports/all.txt "${ALL[@]}"'
[ -f "$RP/all.txt" ] && [ "$(wc -l < "$RP/all.txt")" = 3 ] && hint "only the OK lines: write  > reports/all.txt 2>&1  (the 2>&1 goes AFTER the > file)"
check "reports/exit-code.txt holds just 1"                      '[ "$(tr -d " \t\n" < reports/exit-code.txt)" = 1 ]'
[ -f "$RP/exit-code.txt" ] && [ "$(tr -d ' \t\n' < "$RP/exit-code.txt")" = 0 ] && hint "0 is the exit code of the command you ran just before echo \$?, not of the script. Run the script, then echo \$? immediately"
check "reports/summary.txt = 'down: 2'"                         'same reports/summary.txt "down: 2"'
check "status.txt = 2 old lines + '$TODAY ALERT services down'" 'same status.txt "Health status log" "2026-10-26 all up" "$TODAY ALERT services down"'
if [ -f "$WORK/status.txt" ]; then
  grep -q 'all up' <(tail -n 1 "$WORK/status.txt") && hint "the last line says 'all up': the script failed, so only the || part should run"
  grep -q '\$(date' "$WORK/status.txt" && hint "the text \$(date +%F) was written literally: use double quotes, not single quotes"
  [ "$(wc -l < "$WORK/status.txt")" -gt 3 ] && hint "too many lines: run setup again or fix status.txt; use && / || so only ONE message is added"
fi
summary
