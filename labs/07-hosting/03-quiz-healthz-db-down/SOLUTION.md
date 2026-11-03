# Solution - 03-quiz-healthz-db-down

## 1-2. server.js
In the Files panel open `server.js`. Replace the whole `if (req.url === "/healthz") { ... }` block
(the one that calls `checkDb`) with these two blocks, then Ctrl+S:
```js
  if (req.url === "/healthz") {
    res.end("ok\n");
    return;
  }
  if (req.url === "/readyz") {
    checkDb((ok) => {
      res.statusCode = ok ? 200 : 503;
      res.end(ok ? "ready\n" : "not ready: db down\n");
    });
    return;
  }
```
Why: liveness answers "is the process alive?". The process is alive even when Postgres isn't, so
`/healthz` must not depend on it. The DB check moves to `/readyz`, which a load balancer uses to
stop routing traffic to an instance (no restart).

## 3. Dockerfile
Make it read (one new line, before `CMD`), then Ctrl+S:
```dockerfile
FROM node:24-alpine
WORKDIR /app
COPY server.js .
EXPOSE 3000
HEALTHCHECK --interval=5s --timeout=3s --retries=3 CMD wget -qO- http://127.0.0.1:3000/healthz || exit 1
CMD ["node", "server.js"]
```
Why: Docker runs the `CMD` of the HEALTHCHECK inside the container every 5s. Exit 0 = healthy;
3 failures in a row = unhealthy. `|| exit 1` makes any failure a clean exit code 1.

## 4-5. Build and run
```bash
cd work
docker build -t lab73-api:1.1 .
docker run -d --name lab73-api --network lab73-net -p 127.0.0.1:8303:3000 --env-file app.env lab73-api:1.1
docker ps --filter name=lab73-api          # Up 3 seconds (health: starting) ... then (healthy)
curl -i http://127.0.0.1:8303/readyz       # HTTP/1.1 200 OK ... ready   (the DB is still up)
```
Why `--network lab73-net`: on a user-defined network containers find each other by **name**, so
`DB_HOST=lab73-db` resolves. On the default bridge it would not.

## 6. The outage
```bash
docker stop lab73-db
# wait ~10 s
docker inspect -f '{{.State.Health.Status}}' lab73-api   # healthy
curl -i http://127.0.0.1:8303/healthz     # 200 ok
curl -i http://127.0.0.1:8303/readyz      # 503 not ready: db down
curl -i http://127.0.0.1:8303/hello       # 503 db down
# no curl in your terminal? docker exec lab73-api wget -S -qO- http://127.0.0.1:3000/readyz
```

## Common wrong attempts
- Leaving the DB check in `/healthz` -> after the stop, health goes `unhealthy` after 3 x 5 s.
  An orchestrator would restart every replica during a DB outage: a restart storm that fixes nothing.
- `HEALTHCHECK CMD curl -f ...` -> `curl: not found` in node:24-alpine -> always unhealthy.
  Read the reason with `docker inspect -f '{{json .State.Health}}' lab73-api`.
- `http://localhost:3000/healthz` in the HEALTHCHECK -> can fail on Alpine (`::1`, connection refused).
- Editing `server.js` and running `docker restart lab73-api` -> still the old code. The code is in
  the image: rebuild `1.1`, then `docker rm -f lab73-api` and `docker run` again.
- Forgetting `--network lab73-net` -> `/readyz` is 503 even with the DB up (name not found).
- `HEALTHCHECK` after `CMD` is allowed too, but putting **two** HEALTHCHECK lines keeps only the last.
- Thinking Docker will restart an `unhealthy` container -> plain Docker only **marks** it.
  Restarting on a failed liveness check is the orchestrator's job (Kubernetes livenessProbe, Swarm).
- `docker rm -f lab73-db` instead of `docker stop` -> the check wants the DB stopped, not gone.
