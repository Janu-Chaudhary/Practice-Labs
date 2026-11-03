# Solution - Demos 02

```bash
./traffic.sh > traffic.log 2>&1 &        # customers in the background
./deploy.sh 2.4                          # all gates green: "Deployed v2.4 in ~10 s"
curl -s 'localhost:8080/checkout?customer=kabir&group=1'   # ERROR ... reading 'map' (v2.4)
docker ps                                # tiffingo-2-4-<n>
docker logs tiffingo-2-4-<n>             # TypeError ... at /app/releases/2.4/server.js:13
docker images tiffingo                   # 2.3 still exists, so we can go back to it
./rollback.sh 2.3                        # Start, Check health, Switch: a few seconds
curl -s localhost:8080/healthz           # {"status":"ok","version":"2.3"}
docker exec t5-db psql -U postgres -c 'select version from schema_migrations'   # 2.3, 2.4
cd .. && ./check.sh
```
Why rollback is fast: the 2.3 image already exists and was tested when it was built. Nothing is
tested, built or migrated; a container is only started from it and the load balancer switched.

## Common wrong attempts
- `./deploy.sh 2.3` instead of `./rollback.sh 2.3` -> also ends on v2.3, but runs the whole
  pipeline again (tests, build, migrate check): the slow way back.
- Expecting the rollback to remove `group_id` or the `2.4` row -> rollback never touches the DB.
- `curl localhost:8080/checkout?customer=kabir&group=1` without quotes -> the shell treats `&`
  as "run in background". Quote the URL.
