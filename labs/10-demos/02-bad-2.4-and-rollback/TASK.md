# Demos 02 - Deploy the bad v2.4, then redeploy the previous image (slide 14, steps 3-6)

**Start state (Reset lab did this):** the platform is up and v2.3 is live, deployed through the
pipeline (where stage 01 ended).

**What the professor shows:** Friday 19:00. v2.4 adds "group order". The developer tested with
their own account (asha), who has a saved group. kabir has none, so `members.map(...)` crashes.
Every gate is green, and still **1 in 5 checkouts fail**. At 19:11 he goes back with
`./rollback.sh 2.3`: start the old image again. No test, no build, no migration.

**Slide ideas:**
- Gates only catch what they check: the tests cover `pricing.js`, `/healthz` only runs `SELECT 1`.
- "Three ways back": revert + pipeline (minutes) > **redeploy the previous image (~1 min hosted,
  seconds here)** > flag off (seconds).
- Rollback changes **code only**. The database stays as the last migration left it. It works here
  because 2.4's migration only **adds** a column that v2.3 ignores.

Read first in the Files panel: `app/releases/2.4/server.js` (find `GROUPS` and `members.map`) and
`app/releases/2.4/migrate.sql` (`ADD COLUMN group_id`).

## Do this, in order
1. Start the traffic: `./traffic.sh > traffic.log 2>&1 &`
2. `./deploy.sh 2.4` - all six gates pass.
3. Open `traffic.log` (reopen to refresh): every 5th line is
   `ERROR  Cannot read properties of undefined (reading 'map')  (v2.4)`.
4. Try it yourself (quote the URL, it contains `&`):
   `curl -s 'localhost:8080/checkout?customer=asha&group=1'` -> `ok ... group (v2.4)`
   `curl -s 'localhost:8080/checkout?customer=kabir&group=1'` -> `ERROR ... (v2.4)`
5. Evidence from the container: `docker ps` (name `tiffingo-2-4-...`), then
   `docker logs tiffingo-2-4-<the number>` - the stack trace points to `releases/2.4/server.js:13`.
6. What can we go back to? `docker images tiffingo` - `2.3` is still there.
7. `./rollback.sh 2.3` - only 3 steps (Start, Check health, Switch), a few seconds.
8. `curl -s localhost:8080/healthz` -> version 2.3; `traffic.log` is all ok again.
9. The DB was not rolled back:
   `docker exec t5-db psql -U postgres -c 'select version from schema_migrations'` -> 2.3 **and 2.4**.

## What will be checked
- image `tiffingo:2.4` exists (2.4 went through the pipeline) and `traffic.log` shows its error
- `/healthz` says 2.3; exactly one app container, from `tiffingo:2.3`
- `schema_migrations` still lists `2.4`, and `orders` still has `group_id` (DB untouched)
- kabir's group order answers `ok ... (v2.3)`
