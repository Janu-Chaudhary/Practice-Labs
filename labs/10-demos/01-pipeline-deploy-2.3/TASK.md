# Demos 01 - Start the platform and deploy v2.3 (slide 14, steps 1-2)

**What the professor shows:** TiffinGo, a tiny food-ordering app. `./setup.sh` starts the
"platform": a Docker network `tiffingo`, a Postgres container `t5-db`, and a load balancer
`t5-proxy` (Caddy) on http://localhost:8080. Then `./deploy.sh 2.3` runs the **pipeline**.

**Slide idea:** a pipeline is a row of gates: **Test -> Build -> Migrate -> Deploy -> Check health
-> Switch**. Any gate fails, the pipeline stops and production is unchanged. **Build once, tag
twice**: one image called both `tiffingo:2.3` (version) and `tiffingo:<code id>` (stands in for the
commit id).

**Before the first stage (once only):** the images `node:22-alpine`, `caddy:2.8.4-alpine` and
`postgres:16-alpine` must be on this machine. If Reset lab printed "Missing Docker images", run
this in the terminal (takes a few minutes, needs internet), then press Reset lab:
```
../../../../demos/t5/preflight.sh
```
Port 8080 must be free.

The terminal opens in `work/`, which holds a copy of the professor's `t5-pipeline` folder. Open
`deploy.sh` and `app/releases/2.3/migrate.sql` in the Files panel to read them.

## Do this, in order
1. `./setup.sh` - start the platform. Output ends `Platform ready. Nothing deployed yet.`
2. `./deploy.sh 2.3` - watch the six gates `[1/6]` ... `[6/6]`. Look for the build line
   `tiffingo:2.3 = tiffingo:cdf64da` (one build, two tags) and the migration that creates `orders`.
3. The professor uses a second terminal for traffic. Here there is one terminal, so run the fake
   customers **in the background into a log file**:
   `./traffic.sh > traffic.log 2>&1 &`
   (`>` sends output to the file, `2>&1` sends errors there too, `&` gives you the prompt back.)
   Open `traffic.log` in the Files panel and reopen it to see new lines: `ok order #.. (v2.3)`.
4. `curl -s http://localhost:8080/healthz` - which version is live? `{"status":"ok","version":"2.3"}`
5. `docker images tiffingo` - two tags, the **same IMAGE ID**.
6. `docker ps` - `t5-db`, `t5-proxy` and one `tiffingo-2-3-...` container.
7. Optional: `docker exec t5-db psql -U postgres -c 'select * from schema_migrations'` - the
   pipeline recorded migration `2.3`.

Leave the traffic loop running; Reset lab stops it. (To stop it yourself: `kill %1`.)

## What will be checked
- `t5-db` and `t5-proxy` are running; `/healthz` on :8080 says version 2.3
- exactly one app container, from `tiffingo:2.3`
- `tiffingo:2.3` shares its IMAGE ID with a second tag (build once, two tags)
- `schema_migrations` holds `2.3`; a checkout via :8080 answers `ok ... (v2.3)`
- `traffic.log` in work/ has ok checkouts on v2.3
