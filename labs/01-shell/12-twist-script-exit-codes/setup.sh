#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
mkdir bin config
cat > bin/healthcheck.sh <<'SCRIPT'
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
chmod 644 bin/healthcheck.sh
printf '%s\n' orders=up payments=down users=up search=down health=up > config/services.conf
printf '%s\n' "Health status log" "2026-10-26 all up" > status.txt
banner "12 scripts and exit codes (Twist): chmod +x, ./script, 2>, 2>&1, \$?, &&/||, \$( )"
