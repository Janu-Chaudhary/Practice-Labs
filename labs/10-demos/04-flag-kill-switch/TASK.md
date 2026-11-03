# Demos 04 - The same bug behind a flag: the kill switch (slide 18, steps 10-12)

**Start state (Reset lab did this):** platform up, v2.3 live (deployed through the pipeline).

**What the professor shows:** v2.5 has the **same** group-order bug as v2.4, but wrapped in an
`if` that reads the flag `group_order` from the database on every request. The migration creates
the `flags` table with the flag **OFF**. `./flag.sh on` -> kabir's group orders fail on the next
request. `./flag.sh off` -> fixed on the next request. No deploy, no new container.

**Slide ideas:**
- "A flag is an if-statement whose condition lives outside the code."
- Kill switch = the fastest way back (seconds): revert + pipeline (minutes) > redeploy previous
  image (~1 min) > **flag off (seconds)**. The slide-17 poll answer: switch the flag off.
- "Read on every request": changes land at once, but every request hits the database.

Read first in the Files panel: `app/releases/2.5/server.js` (`flagOn`, `group && await flagOn(...)`)
and `app/releases/2.5/migrate.sql` (`INSERT INTO flags VALUES ('group_order', false)`).

## Do this, in order
1. `./traffic.sh > traffic.log 2>&1 &`
2. `./deploy.sh 2.5` - flag starts OFF: kabir's group orders come back as `single`, no errors.
3. `docker ps` - note the container name `tiffingo-2-5-<n>`.
4. `./flag.sh on` - prints the `UPDATE flags SET enabled = true ...`. Wait a few seconds; in
   `traffic.log` every 5th line is `ERROR ... reading 'map' (v2.5)`.
   Try: `curl -s 'localhost:8080/checkout?customer=asha&group=1'` -> `ok ... group (v2.5)`.
5. `./flag.sh off` - errors stop on the very next request.
6. `curl -s localhost:8080/healthz` -> still 2.5. `docker ps` -> the **same** container as step 3.
7. Proof it was this container: `docker logs tiffingo-2-5-<n>` shows the TypeError from step 4.

Do not redeploy or roll back here: the point is that only one database row changed.

## What will be checked
- `/healthz` says 2.5; exactly one app container, from `tiffingo:2.5`
- `traffic.log` shows the `reading 'map'` error on v2.5 (the flag was on while traffic ran)
- the live container's own `docker logs` show that error (same container, no redeploy)
- `group_order` is OFF in `flags`; kabir's group order answers `ok ... single (v2.5)`
