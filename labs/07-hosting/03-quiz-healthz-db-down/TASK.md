# 03 - Healthy while the database is down (Quiz-style)

**Context:** `work/` holds `lab73-api`: `server.js`, a `Dockerfile` and `app.env`
(`DB_HOST=lab73-db`, `DB_PORT=5432`). Setup started its Postgres database as container `lab73-db`
on the user-defined network `lab73-net`. No API image is built yet.

Today `/healthz` opens a connection to the database. The plan is to run several replicas behind
an orchestrator that **restarts** any instance whose liveness check fails. When Postgres had a
2-minute outage last week, every API instance was restarted at once, for nothing: restarting the
API can't fix the database.

The rule from the lecture:
- **liveness** `/healthz` = "is this process alive?" -> must NOT touch the database. Fail = restart.
- **readiness** `/readyz` = "can I serve traffic right now?" -> checks the database. Fail = the
  load balancer stops sending traffic, **no** restart.

**Task:**

1. In `server.js`, make `/healthz` answer status 200 with body `ok` **without** calling `checkDb`.
2. Add a `/readyz` route: 200 `ready` when `checkDb` succeeds, otherwise 503 `not ready: db down`.
   Keep `/hello` as it is.
3. Add a `HEALTHCHECK` to the `Dockerfile` that calls `http://127.0.0.1:3000/healthz` every 5 seconds
   (timeout 3s, 3 retries). The image has `wget`, not `curl`.
4. Build the image as `lab73-api:1.1`.
5. Run it in the background as `lab73-api`, on network `lab73-net`, host `127.0.0.1:8303` -> container
   `3000`, settings from `app.env`.
6. Simulate the outage: stop `lab73-db` (don't remove it). Wait about 10 seconds.
   `docker ps` must show `lab73-api` as `(healthy)` while `/readyz` and `/hello` answer 503.

**Stop rules:** don't edit `app.env` or `checkDb`. Leave `lab73-api` running and `lab73-db` stopped.

**Hints**
- Edit `server.js` and `Dockerfile` in the Files panel, Ctrl+S. Rebuild after every edit:
  a running container never sees file changes, only a new image + new container does.
- `HEALTHCHECK [OPTIONS] CMD command` - options are `--interval`, `--timeout`, `--retries`.
  The command must exit 0 for healthy. `wget -qO- URL` exits 1 on a non-2xx answer.
- Write `127.0.0.1`, not `localhost`: inside Alpine, `localhost` may resolve to the IPv6 `::1`,
  and the server only listens on IPv4.
- Health status: `docker inspect -f '{{.State.Health.Status}}' lab73-api` (`starting` -> `healthy`).
  The last results: `docker inspect -f '{{json .State.Health}}' lab73-api`.
- Test without curl: `docker exec lab73-api wget -qO- http://127.0.0.1:3000/healthz`.
  `wget -S` also prints the status line (`HTTP/1.1 503 ...`).

**What will be checked**
- `Dockerfile` has a `HEALTHCHECK ... CMD ... /healthz`; image `lab73-api:1.1` carries it
- `lab73-api` runs `1.1` on `lab73-net`, `127.0.0.1:8303` -> 3000, with `DB_HOST=lab73-db`
- `lab73-db` is stopped
- with the DB down: `/healthz` = 200 `ok`, `/readyz` = 503, `/hello` = 503
- `docker inspect` health status of `lab73-api` = `healthy`
