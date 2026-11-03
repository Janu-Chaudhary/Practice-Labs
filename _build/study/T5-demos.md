# T5 Continuous Safe Delivery: the lecture demos, explained

Source: `t5-demos/` (README.md, preflight.sh, reset-all.sh, lib/demo-lib.sh, t5-pipeline/*, t5-rollout/*). I read every file and ran none of them. The rollout numbers in section 4 come from my own re-implementation of the same SHA-256 bucket function, so they match what the demo prints.
Safety: nothing in the archive is malicious. The scripts only touch Docker objects named `tiffingo*`, `t5-db`, `t5-proxy` and the network `tiffingo`, plus the files `.state/`, `flags.json` and `.state.json`.

There are two demos:

| Demo | Slides | One-line story |
|---|---|---|
| `t5-pipeline` (12 steps, two terminals) | 14 (redeploy previous image), 15 (what going back cannot undo), 18 (flags) | TiffinGo's Friday 19:00 incident. Deploy v2.3, then the broken v2.4. Roll back. Rename a column, which a rollback can't fix. Then the same bug behind a flag, used as a kill switch. |
| `t5-rollout` (9 steps) | 19 (three kinds of flag, `hash(user_id) % 100 < 10`) | How "10% of users" works: sticky SHA-256 buckets, why `Math.random()` is wrong, a 10→50→100→0 rollout, and why the flag name is part of the hash. |

---

## 1. Each demo step by step, as the professor runs it

### Demo 1: `t5-pipeline/demo.sh` (Terminal 1) plus `traffic.sh` (Terminal 2)

The demo pauses for Enter after every step. `./demo.sh N` resumes at step N, and `DEMO_NOPAUSE=1` runs it without stopping.

**Terminal 2, `./traffic.sh`: fake customers.** It runs a loop that never ends and sleeps 0.3 s per request (the comment says 3 per second):
- Every 5th request is `GET /checkout?customer=kabir&group=1`, a group order. kabir has **no saved group**.
- The other four rotate through `ravi, meena, zoya, asha` with `group=0`.
- It prints a green line for `ok …`, a red line for `ERROR …`, and a yellow line for "no answer" or anything else.
- So when group orders are broken, **exactly 1 in 5 (20%) of requests fail**. This is the slide's "Checkout returns errors for 1 in 5 orders."

Response formats (from `common/base.js`):
- `/healthz` → `{"status":"ok","version":"2.3"}`. It only runs `SELECT 1` against the database.
- `/checkout` → `ok     order #17  Rs 240  single  (v2.3)`, or `ERROR  <message>  (v2.4)` with HTTP 500.

**Part A: slide 14, "redeploy the previous image"**

| Step | What runs | What the audience sees |
|---|---|---|
| 1 | `./reset.sh` (silent), then `./setup.sh`, then `./deploy.sh 2.3` | The platform starts (network `tiffingo`, Postgres `t5-db`, Caddy `t5-proxy` on :8080). The 6-stage pipeline deploys v2.3. Prompt: start `./traffic.sh` in a second terminal. Every checkout is green: `Rs 240 single (v2.3)`. |
| 2 | `curl -s http://localhost:8080/healthz` | `{"status":"ok","version":"2.3"}`. "It's Friday, 19:00." |
| 3 | A coloured `diff -u releases/2.3/server.js releases/2.4/server.js`, then `cat releases/2.4/migrate.sql` | Two lines are highlighted. `const GROUPS` is marked "only the developer's own account has a saved group". `members.map` is marked "kabir has no saved group, so members is undefined". The migration is shown in green as `ADD COLUMN … safe: old code ignores the new column`. Note: "The migration only ADDS a column. Keep that in mind." |
| 4 | `./deploy.sh 2.4` | Tests pass (3), the build succeeds, the migration is applied, the health check passes, traffic switches. **Terminal 2 then shows a red line on every 5th request**: `ERROR Cannot read properties of undefined (reading 'map') (v2.4)`. Note: "Tests passed. Health check passed. And 1 in 5 checkouts fail." **The gates didn't catch it**, because the tests only cover pricing and the health check only runs `SELECT 1`. |
| 5 | `docker images tiffingo` | Every release built so far is still an image: `tiffingo:2.3`, `tiffingo:2.4` and their 7-character content-id tags. |
| 6 | `./rollback.sh 2.3`, then `curl /healthz` | "No test, no build, no migration. Watch the timer." It prints `Back on v2.3 in ~2 s`, `/healthz` says 2.3, and Terminal 2 is all green again. Note: "On a hosted platform ~1 minute; locally, seconds." This rollback works because the 2.4 migration only *added* a nullable column, which v2.3 ignores. |

**Part B: slide 15, "what going back cannot undo" (the slide-6 poll, for real)**

| Step | What runs | What the audience sees |
|---|---|---|
| 7 | `cat releases/2.4-rename/migrate.sql`, then `./deploy.sh 2.4-rename` | `RENAME COLUMN items TO order_items` is shown in **red**: "breaks code that still uses the old name". **Key moment:** the pipeline migrates (step 3/6) *before* it starts the new code (step 4/6). For those few seconds **v2.3 is still serving and already failing**: every request is red with `column "items" of relation "orders" does not exist (v2.3)`. After the switch, v2.4-rename serves single orders fine, and kabir's group orders still crash (the same `.map` bug). |
| 8 | `./rollback.sh 2.3`, then `curl /healthz`, then `docker exec t5-db psql -U postgres -c '\d orders'` | `/healthz` reports **healthy, v2.3**, yet **every checkout fails** (100% red): `column "items" … does not exist`. `\d orders` shows `order_items` and no `items`. Note: "The code went back. The column didn't. **Code is reversible, data is not.**" This answers the slide-6 poll: **B, checkout fails on v2.3 too.** |
| 9 | `docker exec t5-db psql -U postgres -c 'ALTER TABLE orders RENAME COLUMN order_items TO items;'` | **Fix forward**: a new migration that renames the column back, and Terminal 2 recovers. Note: "With expand-contract, v2.4 would have added order_items and kept items." This manual fix is *not* recorded in `schema_migrations`. |

**Part C: slide 18, flags**

| Step | What runs | What the audience sees |
|---|---|---|
| 10 | A coloured `diff 2.4/server.js 2.5/server.js`, `cat 2.5/migrate.sql`, then `./deploy.sh 2.5` | The only change is `flagOn(db,"group_order")`, which reads `SELECT enabled FROM flags` on **every request**. The bug is still in the code. The migration creates the `flags` table and inserts `('group_order', false)`, so the flag starts OFF. After the deploy, kabir's group orders go through as **single** orders (`Rs 240 single (v2.5)`), with no errors. |
| 11 | `./flag.sh on` | Prints `UPDATE flags SET enabled = true WHERE name='group_order';`. On kabir's next group order Terminal 2 turns red. **No deploy happened.** |
| 12 | `./flag.sh off`, then `curl /healthz` | This is the **kill switch**. The errors stop on the next request ("count the seconds"), and `/healthz` is still v2.5. "Everything else in v2.5 kept running." After Enter it runs `./reset.sh` (stop traffic.sh with Ctrl-C first). |

This walks through the slide's "three ways back" in increasing speed. Redeploying the previous image takes seconds to a minute (steps 5-6). A flag takes seconds (steps 11-12). Reverting the commit and running the pipeline again (minutes) is only mentioned, not run.

### Demo 2: `t5-rollout/demo.sh` (slide 19)

Each step runs `docker run --rm -v "$PWD":/demo -w /demo node:22-alpine node rollout.js <cmd>`, so Node isn't needed on the host.

| Step | Command | What it shows |
|---|---|---|
| 1 | Resets `flags.json` to 10 and deletes `.state.json`, then `cat flags.json` | `{ "group_order": { "rollout_percent": 10 } }`. "The code never contains the number 10." |
| 2 | `sed -n '/BEGIN bucket/,/END bucket/p' rollout.js` | Shows the `bucket()` and `isOn()` functions. |
| 3 | `node rollout.js explain asha ravi meena kabir zoya` | Each user's hash, number and bucket. At 10%, **only meena is ON**. "The bucket never changes for that user and flag." |
| 4 | `node rollout.js spread` | 10,000 users in a 10×10 grid of buckets, with buckets 0-9 in green. **Bold: "Buckets 0 to 9: 1,005 users = 10.05% of 10,000."** "Single buckets wobble, ten together ≈ 10%." |
| 5 | `node rollout.js spread 1000000` | The same at 1 M users. The smallest and largest buckets get relatively closer to the average (law of large numbers). |
| 6 | `node rollout.js random asha` | Two rows of 10 opens. `Math.random() < 0.10` flickers ON/off at random. `bucket("group_order","asha") < 10` gives the **same answer** every time (asha = 67, so off ×10). "random(): the button appears and disappears." |
| 7 | `rm .state.json`, then `rollout` at 10, then `echo …50… > flags.json` and `rollout`, then 100 and `rollout` | 10% gives 1,005 ON. 50% gives 4,957 ON: stayed ON 1,005, newly ON 3,952, **turned off 0**. 100% gives 10,000: stayed 4,957, newly 5,043, turned off 0. "Nobody who had the feature lost it. **Buckets don't move, only the line does.**" |
| 8 | `echo …0… > flags.json`, then `rollout` | Kill switch: 0 ON. Compared with 100%: stayed 0, newly 0, **turned off 10,000** (in red). "One edit, no deploy." |
| 9 | `node rollout.js overlap` | Two flags at 10% each. With `hash(flag:user)`, group_order has 1,005, new_menu 1,016, and **99 are in both** (≈1% = 10% × 10%, what chance gives). With `hash(user)` only, both flags have 978 and **all 978 are in both**: "the same 1,000 people test every new feature." The step then resets `flags.json` to 10%. |

---

## 2. Architecture of `t5-pipeline`

```
host :8080 ──► t5-proxy (caddy:2.8.4-alpine)  ── network "tiffingo" ──►  tiffingo-2-3-<epoch>:3000  (node:22-alpine + pg)
                 Caddyfile bind-mounted from ./.state → /etc/caddy           │ DATABASE_URL=postgres://postgres:postgres@t5-db:5432/postgres
                                                                              ▼
                                                                   t5-db (postgres:16-alpine), tables: schema_migrations, orders, [flags]
```

Names come from `t5-lib.sh`: `NET=tiffingo`, `DB=t5-db`, `PROXY=t5-proxy`, `STATE=./.state` (holds `Caddyfile`, `live` = container name, `live_version` = release). App containers are **not** published to the host. Only the proxy publishes `-p 8080:8080`, and the app listens on `PORT` (default 3000).

### setup.sh: the "platform"
```bash
docker network create tiffingo
docker run -d --name t5-db --network tiffingo -e POSTGRES_PASSWORD=postgres postgres:16-alpine
until docker exec t5-db pg_isready -U postgres -h 127.0.0.1; do sleep 1; done
docker exec -i t5-db psql -U postgres -X -q -v ON_ERROR_STOP=1 \
  -c "CREATE TABLE schema_migrations (version text PRIMARY KEY, applied_at timestamptz DEFAULT now());"
# Caddyfile:  { admin localhost:2019; auto_https off }  :8080 { respond "TiffinGo: nothing deployed yet" 503 }
docker run -d --name t5-proxy --network tiffingo -p 8080:8080 -v "$PWD/.state:/etc/caddy" caddy:2.8.4-alpine
```
It refuses to run if `t5-db` already exists ("Run ./reset.sh first").

### deploy.sh `<release>`: the 6-stage pipeline (slide "The order of the steps")
If any stage fails, it prints `Pipeline stopped. Production is unchanged: still v<live>.` and exits with code 1. **This is the gate behaviour.**

1. **Test** in a fresh, throwaway container: `docker run --rm -v "$APP_DIR/common:/t:ro" -w /t node:22-alpine node --test pricing.test.js`. A non-zero exit stops the pipeline. It prints `3 tests passed`, parsed from the `# pass` line.
2. **Build once, two tags.** `ID=$(cat Dockerfile package.json common/*.js releases/$REL/* | shasum | cut -c1-7)` is a content hash that stands in for the commit id. Then:
   `docker build -q --build-arg RELEASE=$REL -t tiffingo:$REL -t tiffingo:$ID app`. It prints `tiffingo:2.4 = tiffingo:ab12cd3`. This matches the slide: "Build once, tag with commit id, promote the same image."
3. **Migrate before deploy.** If `SELECT 1 FROM schema_migrations WHERE version='$REL'` returns a row, it prints "already applied". Otherwise it runs `psql < app/releases/$REL/migrate.sql` with `ON_ERROR_STOP=1`, then `INSERT INTO schema_migrations (version) VALUES ('$REL')`. Old code is **still serving** at this point, so every migration must be compatible with the old code.
4. **Deploy beside the old one**: `docker run -d --name tiffingo-<rel with . → ->-<epoch> --network tiffingo -e DATABASE_URL=… tiffingo:$REL`. Old and new run side by side.
5. **Health check**: up to 40 tries × 0.5 s = 20 s of `docker exec <new> wget -qO- http://localhost:3000/healthz`. If it never succeeds, it prints the last 5 log lines, runs `docker rm -f <new>` and stops; the old version keeps serving. This is a *readiness* check: it tests the process plus database connectivity, not business logic.
6. **Switch** (`switch_to`): rewrite `.state/Caddyfile` with `reverse_proxy <new>:3000`, run `docker exec t5-proxy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile`, and record `live`/`live_version`. It then waits `sleep 1` to drain requests and runs `docker rm -f <old>`. This is a **blue-green cut-over**: everything switches at once, with zero downtime. The old container is *not* kept warm, so going back means starting the old image again.

### rollback.sh `<release>`: redeploy the previous image
- `docker image inspect tiffingo:$REL`. If it is missing: "No image tiffingo:$REL. It was never built."
- It runs three stages: **Start** (`start_container`), **Check health**, **Switch**. "Nothing to test, build or migrate: the image already exists." That is why it is fast.
- It **does not touch the database**: no down-migration and no change to `schema_migrations`. That's the whole point of Part B.

### flag.sh on|off: flag storage
- The flag is a **row in Postgres**: `flags(name text PRIMARY KEY, enabled boolean NOT NULL)`, created by the 2.5 migration with `('group_order', false)`.
- `flag.sh` runs `docker exec -i t5-db psql -U postgres -X -q -v ON_ERROR_STOP=1 -c "UPDATE flags SET enabled = true|false WHERE name = 'group_order';"`.
- v2.5 reads it with `SELECT enabled FROM flags WHERE name = $1` **on every request**, with no cache. That's why the change lands on the next request (slide: "read on every request: changes land at once, but every request hits the DB"). A missing row counts as OFF (`rows.length > 0 && rows[0].enabled`). The flag is only queried when `group=1` (short-circuit `&&`).

### traffic.sh: not a traffic splitter
This is important for the quiz. `traffic.sh` is a **load generator**: curl in a loop, every 5th request is a kabir group order. **The demos contain no weighted or canary split.** The proxy always points at exactly one container (blue-green). Canary (5% → grow) appears only on slide 20. If you were asked for a Caddy canary, it would look like `reverse_proxy a:3000 b:3000 { lb_policy weighted_round_robin 95 5 }`, which needs Caddy ≥ 2.8. That is my extrapolation; the demo doesn't contain it.

### reset.sh / reset-all.sh
- `reset.sh` runs `docker rm -f` on `tiffingo-*`, `t5-db` and `t5-proxy`, then `docker network rm tiffingo` and `docker rmi -f` on all `tiffingo` images, then `rm -rf .state`.
- `reset-all.sh` also rewrites `t5-rollout/flags.json` to 10% and deletes `.state.json`.

### The Dockerfile (one file for every release)
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund      # deps layer cached unless package*.json change
COPY common ./common
ARG RELEASE
COPY releases/${RELEASE} ./releases/${RELEASE}
ENV RELEASE=${RELEASE}
CMD ["sh", "-c", "node releases/$RELEASE/server.js"]
```
`.dockerignore` contains `node_modules`. The only dependency is `pg@8.23.1`. The layer order is the same idea as quiz 2A Q15: copy the manifests, run `npm ci`, then copy the code.

---

## 3. The release story, 2.3 → 2.4 → 2.4-rename → 2.5

| Release | server.js | migrate.sql | Safe to roll back to 2.3 afterwards? |
|---|---|---|---|
| **2.3** | Single orders only. `INSERT INTO orders (customer, items, total)` with items `"paneer thali, lassi"` = Rs 240, kind `single`. | `CREATE TABLE IF NOT EXISTS orders (id serial PK, customer text, items text, total int, created_at timestamptz default now())` | n/a (baseline) |
| **2.4** | Adds the group order: `GROUPS = { asha: [asha, ravi, meena] }`. If `group`, then `members = GROUPS[customer]; items = members.map(() => "paneer thali")` gives one thali per member (asha: Rs 540). The INSERT now includes `group_id`. **Bug:** any customer without a saved group (kabir) has `members` undefined, so it throws a TypeError and returns a 500. | `ALTER TABLE orders ADD COLUMN IF NOT EXISTS group_id int;` (**expand only**: nullable, so old code ignores it) | **Yes.** The code is broken but the schema is backward compatible, so `rollback.sh 2.3` fixes everything. |
| **2.4-rename** | Same code and same bug, but it writes to `order_items` instead of `items`. Version string `"2.4-rename"`. | `ADD COLUMN IF NOT EXISTS group_id int;` **plus** `ALTER TABLE orders RENAME COLUMN items TO order_items;` | **No. This is the unsafe release.** The rename breaks v2.3 *during* the deploy (the migration runs before the switch) and *after* a rollback. The only way out is **forward**, with a new migration that renames it back. |
| **2.5** | The same group code wrapped in `const groupOrder = group && await flagOn(db,"group_order"); if (groupOrder) {…}`. When the flag is OFF, a group request is served as a single order. It uses `items` again. | `ADD COLUMN IF NOT EXISTS group_id int; CREATE TABLE IF NOT EXISTS flags (name text PRIMARY KEY, enabled boolean NOT NULL); INSERT INTO flags VALUES ('group_order', false) ON CONFLICT DO NOTHING;` | Yes, but you don't need to: `flag.sh off` turns the feature off in seconds while everything else in v2.5 keeps running. |

**Why 2.4-rename is unsafe.** A `RENAME`, `DROP COLUMN` or `DROP TABLE` (which `show_sql` paints red) breaks code that still uses the old name. Two different code versions use the database at once: the old code during deploy stage 4, and the old code again after a rollback. **Rollback reverts code, not data or schema.**

**The safe way (expand/contract, also called parallel change).** The slide-12 exercise asks for the full sequence of deploys to rename a column, and where it becomes irreversible:
1. **Expand:** migrate `ADD COLUMN order_items text`. The old code is unaffected.
2. Deploy code that **writes both** `items` and `order_items` and reads `items`.
3. **Backfill:** `UPDATE orders SET order_items = items WHERE order_items IS NULL;`
4. Deploy code that **reads `order_items`** and still writes both. You can still roll back to step 2 or 3.
5. Deploy code that **only uses `order_items`**. Its migration must leave `items` in place, so if the column has a NOT NULL constraint, drop that constraint now (old rows can't break and new rows don't fill `items`).
6. **Contract:** `ALTER TABLE orders DROP COLUMN items;` ← **this is the irreversible point.** The data is gone, and no previous image can run against this schema.

**How rollback and flags save the day:**
- **2.4 incident:** detect (traffic goes red), decide, act: `rollback.sh 2.3`, about 2 s locally (~1 min hosted). This works only because the migration was additive.
- **2.4-rename:** rollback **doesn't** help (healthy `/healthz`, 100% failing checkouts). You have to fix forward with `ALTER TABLE orders RENAME COLUMN order_items TO items;`.
- **2.5:** the bug ships *dark* behind a flag. Turning the flag on shows the bug, and turning it off is a kill switch in seconds with no deploy. This answers the slide-17 poll ("split the bill" charges the wrong friend): **C, switch the flag off.**

---

## 4. rollout.js and flags.json

**Flag schema:** `flags.json` = `{ "group_order": { "rollout_percent": 10 } }`. There is one integer field per flag, read with `JSON.parse(fs.readFileSync("flags.json"))[name]` **on every call**. There are no `enabled` or `targets` fields: targeting (e.g. "Pune first") is on the slide only.

**Algorithm (between the BEGIN and END bucket markers):**
```js
function bucket(flagName, userId) {
  const digest = crypto.createHash("sha256").update(flagName + ":" + userId).digest();
  const n = digest.readUInt32BE(0);   // first 4 bytes, big-endian, 0..4,294,967,295
  return n % 100;                     // 0..99
}
function isOn(flagName, userId) { return bucket(flagName, userId) < readFlag(flagName).rollout_percent; }
```
- **Deterministic and sticky:** the same (flag, user) pair always gets the same bucket, so users never flicker.
- **Monotonic rollout:** raising the percentage only moves the threshold. Everyone below the old threshold stays ON, so nobody loses the feature when it grows.
- **The flag name is salted into the hash:** each flag gets an independent 10% of users. Otherwise the same users test every feature.
- 0 = nobody (kill switch). 100 = everyone (buckets 0-99 are all < 100).
- Users are generated as `user_1 … user_10000`.

**Commands and their exact output** (values recomputed independently):

`explain asha ravi meena kabir zoya` at 10%:

| user | first 4 bytes of the hash | number | bucket | ON at 10%? |
|---|---|---|---|---|
| asha | 1c386e8f | 473,460,367 | 67 | off (67 ≥ 10) |
| ravi | 9ad54706 | 2,597,668,614 | 14 | off (14 ≥ 10) |
| meena | 5d1c93b1 | 1,562,153,905 | **5** | **ON (5 < 10)** |
| kabir | 443daf98 | 1,144,893,336 | 36 | off |
| zoya | f6b7a02e | 4,139,229,230 | 30 | off |

At 50%, meena, ravi, kabir and zoya are ON and asha (67) is off. At 15%, ravi is ON too. At 100%, everyone is ON.

| Command | Output |
|---|---|
| `spread` (10,000, at 10%) | `Buckets 0 to 9: 1,005 users = 10.05% of 10,000.` Smallest bucket 72 (−28%), largest 133 (+33%), average 100. |
| `rollout` at 10 / 50 / 100 / 0 | 1,005 / 4,957 / 10,000 / 0 users ON. Going up, "turned off" is always 0. Going 100 → 0 turns off 10,000. |
| `overlap` | `hash(flag name + user id): group_order 1005, new_menu 1016, in both: 99` and `hash(user id) only: group_order 978, new_menu 978, in both: 978` |
| `random asha` | The `Math.random()` row varies on every run. The bucket row is `off` ×10 (asha = 67). |
| anything else | `usage: node rollout.js explain\|spread\|random\|rollout\|overlap` |

`rollout` saves `{percent, on:[…]}` to `.state.json` so the next run can compare against it ("stayed ON / newly ON / turned off").

---

## 5. pricing.js and pricing.test.js: the test gate

- `MENU = { "paneer thali": 180, "veg biryani": 160, "lassi": 60, "gulab jamun": 50 }`. `total(items)` sums the prices, and **unknown items count as 0**.
- The tests run with Node's built-in runner (`node --test`, no dependencies) and use `assert.strictEqual`:
  - `one thali` → 180
  - `thali and lassi` → 240
  - `empty cart` → 0
- Pipeline role: stage 1/6, run in a throwaway `node:22-alpine` container with `common/` mounted read-only. If any test fails, Node exits non-zero, `deploy.sh` stops, there is no build or migration, and **"Production is unchanged."** This is the slide's "each step's exit code says pass or fail. One failure stops the job."
- **The lesson is the gap:** the comment says "They all pass, for every release." The tests cover pricing, not checkout or group orders, so v2.4 is green through test, build and health and still fails 20% of real traffic. Gates only catch what they check. That's why you still need detection (alerts), fast rollback and flags.
- `rollback.sh` skips this gate on purpose, because the image was already tested when it was built.

---

## 6. Concepts mapped to slide terms

| Demo moment | Slide term |
|---|---|
| `deploy.sh` stages 1-6 in order; stop on first failure | "The order of the steps": Test, Build, Migrate, Deploy, Check health. "Each step's exit code says pass or fail." |
| `node --test` in a `--rm` container | "CI job runs on a fresh computer… thrown away" |
| `-t tiffingo:2.4 -t tiffingo:<id>`, `docker images tiffingo` | "Build once, promote the same parcel; tag it with the commit id" (`tiffingo:3f9a2c1`) |
| Migrate before the new container starts; v2.3 fails during the 2.4-rename deploy | "During step 4, old and new code run side by side"; migrations must be compatible with old code |
| `health_check` via `/healthz`; a failed check kills only the new container | Check health / readiness checks decide which servers get traffic |
| Caddy reload to a new container, old one removed | Blue-green ("switch all at once, switch back at once") |
| `rollback.sh 2.3` | "Three ways back: redeploy the previous image, ~1 minute, nothing is rebuilt" |
| Step 8, healthy but failing; `\d orders` | "What going back cannot undo: a dropped or renamed column… Code is reversible. Data is not." |
| Step 9, rename back | Fix forward; expand-contract |
| traffic.sh 1 in 5 red | The incident: "errors for 1 in 5 orders"; time to recover = detect + decide + act |
| v2.5 `flagOn()`, `flags` table, `flag.sh` | "A flag is an if-statement whose condition lives outside the code"; kill switch; "Switch the feature off with a flag. Seconds" |
| Flag read on every request | "How fast does a flag change land?" (read every request vs cache 30 s / 5 min) |
| rollout.js `bucket()` | Percentage rollout `hash(user_id) % 100 < 10`, not `random() < 0.1` |
| 10 → 50 → 100, "turned off: 0" | Gradual rollout, sticky users |
| `overlap` | Salting the hash with the flag name. Also relevant to flag-name hygiene (Knight Capital reused an old flag name) |
| 0% | Kill switch |
| (not demoed) | Targeted flags (Pune first), canary 5%, flag debt (owner and removal date), Knight Capital, flag services |

---

## 7. Likely quiz terminal tasks, with solutions and checker expectations

Past terminal tasks (quiz 2A Q14-Q18) share a style: **Docker build/tag/run/volume, Dockerfile layer order, git commits, migration naming, and up/down migrations with flyway on SQLite.** The checker inspects the final state (images, containers, files at HEAD, DB schema). The tasks below follow T5 in that style.

### T1. Build once, two tags (commit id and version)
*"Build the image from the Dockerfile with `--build-arg RELEASE=2.4`, tag it `tiffingo:2.4` and `tiffingo:<short commit id>`."*
```bash
ID=$(git rev-parse --short=7 HEAD)
docker build --build-arg RELEASE=2.4 -t tiffingo:2.4 -t tiffingo:$ID .
# or tag an existing image afterwards:
docker tag tiffingo:2.4 tiffingo:$ID
docker images tiffingo          # same IMAGE ID on both rows
```
**Checker:** both tags exist with the **same image ID** (`docker image inspect -f '{{.Id}}'`), and the image has `ENV RELEASE=2.4`. Don't build twice for two tags: "rebuilding can produce a different image".

### T2. Roll back to the previous image
*"`app` is running from `app:2.4` on host port 8080 → 3000 and is broken. Roll back to `app:2.3`, keep the name `app` and the same port. Don't rebuild."*
```bash
docker images app                          # confirm app:2.3 exists
docker rm -f app                           # free the name and port 8080
docker run -d --name app -p 8080:3000 app:2.3     # add the same -e/--network/-v flags the old one had
docker ps; curl -s localhost:8080/healthz  # {"status":"ok","version":"2.3"}
```
Copy the old container's flags first with `docker inspect app` (look at Env, Mounts, NetworkSettings).
**Checker:** a running container from `app:2.3` publishes 8080 → 3000. There is no running `app:2.4` container. `/healthz` reports 2.3. Image `app:2.4` probably still exists (don't delete it unless asked). No new build was made: `docker images` shows no new image ID.

### T3. Make the v2.4 rename migration backward-compatible (expand/contract)
*"`migrations/V3__rename_items.sql` renames `items` to `order_items`, which breaks the running v2.3. Rewrite it so old code keeps working."* (SQLite or Postgres)
```sql
-- V3__expand_order_items.sql   (expand: additive only)
ALTER TABLE orders ADD COLUMN order_items TEXT;
UPDATE orders SET order_items = items;          -- backfill
-- NO rename, NO drop. Contract (DROP COLUMN items) is a later, separate migration
```
Apply it with `flyway migrate` (check the quiz's flyway conf) or `sqlite3 shop.db < file`.
**Checker:** `PRAGMA table_info(orders)` (or `\d orders`) has **both** `items` and `order_items`. Every existing row has `order_items = items`. Old-style `INSERT INTO orders (customer, items, total)` still works. No `RENAME` or `DROP` appears in the migration. Gotcha: a new column added as `NOT NULL` without a `DEFAULT` will fail on a table that has rows, and will also break old inserts. Keep it nullable or give it a default.

### T4. Fix forward after a rename (step 9 of the demo)
*"v2.3 is live and failing: `column "items" does not exist`. Don't redeploy. Fix the database."*
```bash
docker exec t5-db psql -U postgres -c 'ALTER TABLE orders RENAME COLUMN order_items TO items;'
# SQLite: sqlite3 shop.db 'ALTER TABLE orders RENAME COLUMN order_items TO items;'
# Flyway style: write migrations/V4__rename_back.sql with that line, then flyway migrate
```
**Checker:** the `orders` table has `items` and not `order_items`. Checkout returns `ok`. The row count is unchanged (no data lost). If a migration file is required, it exists with the next version number.

### T5. Up and reverse migrations for the expand/contract steps (modelled on 2A Q18)
- `V3__add_order_items.sql`: `ALTER TABLE orders ADD COLUMN order_items TEXT; UPDATE orders SET order_items = items;`
- `U3__add_order_items.sql` (undo): `ALTER TABLE orders DROP COLUMN order_items;` (needs SQLite ≥ 3.35)
- `V4__add_flags.sql`: `CREATE TABLE flags (name TEXT PRIMARY KEY, enabled BOOLEAN NOT NULL); INSERT INTO flags VALUES ('group_order', 0);`
- `U4__add_flags.sql`: `DROP TABLE flags;`

Note: Flyway `U` (undo) migrations are a paid feature, so the quiz likely uses its own `NN_name.up.sql` / `.down.sql` convention with a runner.
**Checker:** the files exist with the right names, `flyway info` shows them applied, the table and columns exist, and the original 3 rows are still there. The quiz's own naming convention may differ (2A Q18 used `NN_name.up.sql`): follow what the folder already uses.

### T6. Turn a flag off (kill switch), or set a rollout percentage
- **DB flag:**
  ```bash
  docker exec t5-db psql -U postgres -c "UPDATE flags SET enabled = false WHERE name = 'group_order';"
  sqlite3 app.db "UPDATE flags SET enabled = 0 WHERE name = 'group_order';"
  ```
- **JSON flag** (rollout.js style). Set group_order to 0% or 100%, or to 25%:
  ```bash
  printf '{\n  "group_order": { "rollout_percent": 0 }\n}\n' > flags.json
  # or keep other flags intact:
  jq '.group_order.rollout_percent = 0' flags.json > tmp && mv tmp flags.json
  node rollout.js rollout      # "rollout_percent = 0: 0 of 10,000 users ON"
  ```
**Checker:** the DB row has `enabled = false`, or `JSON.parse(flags.json).group_order.rollout_percent === 0`. The file must still be valid JSON. **No new image or container was created** (that's the point: no deploy). The app container is unchanged (same ID, still running).

### T7. Put a feature behind a flag (turn 2.4 into 2.5)
*"Wrap the group-order code in a flag read from the `flags` table; the default is OFF."*
- Add the 2.5 migration (`CREATE TABLE flags…`, `INSERT … ('group_order', false) ON CONFLICT DO NOTHING`).
- In server.js add `async function flagOn(db,name){ const {rows}=await db.query("SELECT enabled FROM flags WHERE name=$1",[name]); return rows.length>0 && rows[0].enabled; }`.
- Change `if (group)` to `const groupOrder = group && await flagOn(db,"group_order"); if (groupOrder)`.
- Change `kind: group ? …` to `kind: groupOrder ? …`.

**Checker:** with the flag off, `GET /checkout?customer=kabir&group=1` returns `ok … single`. With it on, it returns ERROR for kabir and `Rs 540 group` for asha.

### T8. Fix the Dockerfile layer order (exactly like 2A Q15, applied to this Dockerfile)
The correct order: `FROM` → `WORKDIR` → `COPY package.json package-lock.json ./` → `RUN npm ci …` → `COPY common` → `ARG RELEASE` → `COPY releases/${RELEASE}` → `ENV` → `CMD`. Common breakages to spot:
- `RUN npm ci` placed before the COPY of the manifests: it fails with no package.json.
- `COPY . .` placed before `npm ci`: every code change re-runs npm ci.
- A missing `ARG RELEASE` before the `COPY releases/${RELEASE}` line, so the variable is empty.
- `node_modules` missing from `.dockerignore`.

**Checker:** the image tag exists, and `docker history` or the build steps show the COPY of the manifests, then `RUN npm ci`, then the code COPY.

### T9. Test gate: add a test or fix a failing test, then commit (Q16 style)
*"The pipeline runs `node --test`. Add a test showing that an unknown item costs 0" (or "veg biryani + gulab jamun = 210"), "or fix pricing.js so the failing test passes. Commit."*
```js
test("unknown item is free", () => assert.strictEqual(total(["pizza"]), 0));
test("biryani and jamun", () => assert.strictEqual(total(["veg biryani","gulab jamun"]), 210));
```
```bash
node --test common/pricing.test.js     # or: docker run --rm -v "$PWD/common:/t:ro" -w /t node:22-alpine node --test pricing.test.js
git add -A && git commit -m "…"
```
**Checker:** the test file at HEAD has ≥ N tests, all of them pass, and the commit message matches. A gotcha like the one in the demo: a plausible bug is a MENU price typo (thali 18 instead of 180), which makes "one thali" fail.

### T10. CI workflow: gate the build on the tests (if a GitHub Actions file appears)
```yaml
jobs:
  test:  { runs-on: ubuntu-latest, steps: [ {uses: actions/checkout@v4}, {run: node --test common/} ] }
  build: { needs: test, runs-on: ubuntu-latest, steps: [ {uses: actions/checkout@v4},
           {run: 'docker build --build-arg RELEASE=2.5 -t tiffingo:${{ github.sha }} .'} ] }
```
**Checker:** `build` has `needs: test`, and the tag uses the commit SHA, not `latest`. Secrets come from `${{ secrets.X }}` and never from the code.

### T11 (stretch). Blue-green switch by hand
Start `app-green` from `app:2.5` on a network, health-check it (`docker exec app-green wget -qO- localhost:3000/healthz`), then repoint the proxy (edit the Caddyfile and run `docker exec proxy caddy reload --config /etc/caddy/Caddyfile`), then `docker rm -f app-blue`.
**Checker:** the proxy's upstream points at the new container and only one app container is running.

### Five MCQ ideas (with answers)
1. **The pipeline deployed v2.4, tests and `/healthz` passed, and 1 in 5 checkouts fail. Why didn't the gates catch it?**
   A. The health check was too slow. **B. The tests only cover pricing and the health check only runs `SELECT 1`, so neither exercises group checkout. ✓** C. The image was rebuilt for production. D. The migration failed silently.
2. **v2.4's migration renamed `items` → `order_items`. After `rollback.sh 2.3`, `/healthz` reports 2.3 ok. Checkout?**
   A. Recovers. **B. Fails on every request: column "items" does not exist. Rollback restores code, not schema. ✓** C. Fails only for group orders. D. Postgres restores the old column.
3. **Why is redeploying `tiffingo:2.3` faster than reverting the commit?**
   **A. The image already exists: no test, build or migration. ✓** B. Docker caches the database. C. Rollback skips the health check. D. Caddy keeps the old container warm.
4. **Why use `sha256(flag + ":" + user) % 100 < p` instead of `Math.random() < p/100`?**
   **A. The result is deterministic and sticky per user, so the feature doesn't flicker, and raising p never removes it from anyone. ✓** B. SHA-256 is faster than random(). C. It guarantees exactly p% of users. D. It encrypts the user id.
5. **Two flags each at 10% use `hash(user_id)` without the flag name. Overlap?**
   A. About 1% of users. **B. The same ~10%: every experiment hits the same users. ✓** C. 0%. D. 20%.

   Bonus questions:
   - Order the pipeline: Test → Build → **Migrate** → Deploy → Check health.
   - Which migration line is unsafe while old code runs: `ADD COLUMN group_id int` or `RENAME COLUMN items TO order_items`? The rename.
   - Fastest fix when a flagged feature misbehaves? Switch the flag off, in seconds.
   - Where does the expand/contract change become irreversible? At the contract `DROP COLUMN`.

---

## 8. Prerequisites, and how to rebuild a practice lab locally

**What the demos assume:**
- **Docker** with a running daemon. `preflight.sh` also checks `docker compose version`, though these demos never use compose.
- **Host port 8080 free** (Caddy publishes `8080:8080`). App containers use 3000 inside the network only. Caddy's admin API is on localhost:2019 inside the proxy container.
- **Images:**
  - `postgres:16-alpine` (password `postgres`, user `postgres`, db `postgres`)
  - `node:22-alpine` (tests, the app and rollout.js; **no Node needed on the host**)
  - `caddy:2.8.4-alpine`
- The first build needs internet for `npm ci` (`pg@8.23.1`). Preflight pre-builds all 4 releases to warm the cache.
- **Host tools:** bash (3.2-compatible), `curl`, `shasum` (on Linux it comes with perl; if it's missing, substitute `sha1sum`), `perl` (optional, for millisecond timers), `lsof` (preflight only), `awk`, `diff`, `sed`.
- **No psql or sqlite on the host:** everything runs through `docker exec t5-db psql …`.
- Run `chmod +x *.sh */*.sh` first (the README says to; in this copy the scripts already have the exec bit, but `flags.json` and `rollout.js` are mode 600).

**Recreate safely** (copy into your own directory; these are equivalent manual commands, so you don't need to run the downloaded scripts):
```bash
docker network create tiffingo
docker run -d --name t5-db --network tiffingo -e POSTGRES_PASSWORD=postgres postgres:16-alpine
docker exec -i t5-db psql -U postgres < app/releases/2.3/migrate.sql
docker build --build-arg RELEASE=2.3 -t tiffingo:2.3 app
docker run -d --name app --network tiffingo -p 8080:3000 \
  -e DATABASE_URL=postgres://postgres:postgres@t5-db:5432/postgres tiffingo:2.3
curl -s localhost:8080/healthz ; curl -s 'localhost:8080/checkout?customer=kabir&group=1'
# then practise: build 2.4, migrate, swap containers, rollback, the rename, fix forward, flags
docker rm -f app t5-db; docker network rm tiffingo; docker rmi tiffingo:2.3 tiffingo:2.4   # clean up
```
This skips Caddy by publishing the app directly, which is closer to quiz-style `-p 8080:3000` tasks. For the flyway/SQLite-style tasks (T3-T5), practise with `sqlite3 shop.db` and `flyway -url=jdbc:sqlite:shop.db -locations=filesystem:migrations migrate`, which is what the quiz 2A Q18 environment implies.
