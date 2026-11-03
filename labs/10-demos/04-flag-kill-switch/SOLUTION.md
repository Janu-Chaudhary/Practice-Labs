# Solution - Demos 04

```bash
./traffic.sh > traffic.log 2>&1 &
./deploy.sh 2.5              # CREATE TABLE flags; group_order starts OFF
docker ps                    # tiffingo-2-5-<n>
./flag.sh on                 # UPDATE flags SET enabled = true WHERE name = 'group_order';
# wait ~3 s, open traffic.log: ERROR ... reading 'map' (v2.5) every 5th line
./flag.sh off                # the kill switch
curl -s localhost:8080/healthz          # {"status":"ok","version":"2.5"}
docker ps                    # the same tiffingo-2-5-<n>
docker logs tiffingo-2-5-<n> # the TypeError from while the flag was on
cd .. && ./check.sh
```
`./flag.sh` is only `docker exec t5-db psql -U postgres -c "UPDATE flags SET enabled = ..."`.

## Common wrong attempts
- `./flag.sh off` right after `on` with no wait -> no group order arrived while it was on, so
  traffic.log has no error. Wait a few seconds (or curl kabir's group order) before switching off.
- `./rollback.sh 2.3` or `./deploy.sh 2.5` again to "fix" it -> a new container: works, but it is
  the slow way and the check wants the same container.
- `./flag.sh ON` -> usage error: only lower-case `on` / `off`.
