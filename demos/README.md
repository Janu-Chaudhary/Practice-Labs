# Lecture demos

The professor's T5 (Continuous Safe Delivery) demos, ready to run on your own machine.
Watching them once is good. Running them yourself and predicting each output first is better.

```
demos/
  README.md            this file
  t5/
    README.md          the professor's original instructions
    preflight.sh       checks Docker and port 8080, pulls images, pre-builds all releases
    reset-all.sh       stops both demos and deletes everything they created
    lib/demo-lib.sh    shared helpers (step titles, pauses, colours)
    t5-pipeline/       Demo 1: deploy, break, roll back, rename trap, feature flag (slides 14, 15, 18)
      demo.sh            runs the whole story, 12 steps, pauses after each
      setup.sh           the "platform": network + Postgres (t5-db) + Caddy (t5-proxy) on :8080
      deploy.sh <rel>    the 6-stage pipeline: test, build, migrate, deploy, health, switch
      rollback.sh <rel>  redeploy an image that already exists (no test, build or migrate)
      flag.sh on|off     flip the group_order flag in the database (no deploy)
      traffic.sh         fake customers, 3 per second; every 5th is a group order by kabir
      reset.sh           remove this demo's containers, network, images and state
      app/               one Dockerfile + releases 2.3, 2.4, 2.4-rename, 2.5
    t5-rollout/        Demo 2: how "10% of users" works (slide 19)
      demo.sh            9 steps
      rollout.js         the bucket function sha256(flag:user) % 100 < percent
      flags.json         { "group_order": { "rollout_percent": 10 } }
```

The step-by-step walkthrough, with the real output of every step, what to notice, and
"predict before you run" questions, is in the study guide: section **T5 demos (professor)**
(`_build/sections/10-demos.html`, id `demos`).

## Prerequisites

| Need | Why | Check |
|---|---|---|
| Docker, daemon running, usable without sudo | everything runs in containers | `docker info` |
| Host port **8080** free | Caddy (the load balancer) publishes `8080:8080` | `ss -ltn \| grep :8080` prints nothing |
| Images `postgres:16-alpine`, `node:22-alpine`, `caddy:2.8.4-alpine` | DB, app + tests + rollout.js, proxy | `./preflight.sh` pulls them |
| Internet the **first** time | `docker pull` and `npm ci` (installs `pg`) inside the image build | after `./preflight.sh`, builds work offline from cache |
| bash, curl, diff, awk, sed | the scripts | on every Ubuntu |
| `shasum` or `sha1sum`; `lsof` or `ss` | content id of a build; port check | Linux fallbacks added (see below) |

You do **not** need Node, psql or Postgres on the host. Every `node` and `psql` runs inside a container.

## Run it

Once, before anything else (about 2 minutes the first time):

```bash
cd demos/t5
chmod +x *.sh */*.sh
./preflight.sh          # add "smoke" to also deploy 2.3 -> 2.4 -> rollback once and check it
```

It should end with `All good.`

### Demo 1: t5-pipeline (two terminals)

Terminal 1:

```bash
cd demos/t5/t5-pipeline
./demo.sh               # press Enter after each step; ./demo.sh 7 resumes at step 7
```

Terminal 2, after step 1 says so:

```bash
cd demos/t5/t5-pipeline
./traffic.sh            # watch this terminal turn red and green; Ctrl-C stops it
```

Step 12 cleans up after you press Enter (stop `traffic.sh` with Ctrl-C first).

Want to drive it yourself instead of `demo.sh`? These are the same steps:

```bash
./reset.sh; ./setup.sh; ./deploy.sh 2.3       # terminal 2: ./traffic.sh
curl -s localhost:8080/healthz
./deploy.sh 2.4                               # 1 in 5 checkouts fail
docker images tiffingo
./rollback.sh 2.3                             # all green again
./deploy.sh 2.4-rename                        # migration renames items -> order_items
./rollback.sh 2.3                             # healthy, but EVERY checkout fails
docker exec t5-db psql -U postgres -c 'ALTER TABLE orders RENAME COLUMN order_items TO items;'   # fix forward
./deploy.sh 2.5                               # bug is behind a flag, flag starts OFF
./flag.sh on                                  # kabir's group orders fail again
./flag.sh off                                 # kill switch: errors stop on the next request
./reset.sh
```

Run without pauses (no keyboard needed): `DEMO_NOPAUSE=1 ./demo.sh`.

### Demo 2: t5-rollout (one terminal)

```bash
cd demos/t5/t5-rollout
./demo.sh               # or DEMO_NOPAUSE=1 ./demo.sh
```

If Node is installed on the host you can also call it directly: `node rollout.js explain asha meena`,
`node rollout.js spread`, `node rollout.js random asha`, `node rollout.js rollout`, `node rollout.js overlap`.

## Reset

```bash
cd demos/t5
./reset-all.sh
```

It removes only what the demos created: containers `tiffingo-*`, `t5-db`, `t5-proxy`, the network
`tiffingo`, all `tiffingo:*` images, `t5-pipeline/.state/`, `t5-rollout/.state.json`, and sets
`flags.json` back to 10%. The base images (postgres, node, caddy) stay, so the next run is fast.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Already set up. Run ./reset.sh first` | a previous run is still up: `./reset.sh` (or `../reset-all.sh`) |
| `port 8080 is in use` | `./reset-all.sh`; if still busy, `ss -ltnp \| grep :8080` shows which program owns it |
| `permission denied ... docker.sock` | your user is not in the `docker` group: `sudo usermod -aG docker $USER`, then log out and in |
| A deploy stops at `[2/6] Build` | no internet and no cache: run `./preflight.sh` once while online |
| The script stopped halfway | `./demo.sh N` resumes at step N |
| Anything else | `./reset-all.sh`, then start again (about a minute) |

## Linux notes

Tested on Ubuntu (Linux 7.0, Docker 29.9, Compose v5.6) on 2026-11-03. Both demos and
`./preflight.sh smoke` ran end to end and passed. Two small fallbacks were added for Linux machines
that lack the macOS-style tools. Neither changes what the demos teach or print.

- `t5/t5-pipeline/deploy.sh` (content-id line, `ID=$(... | shasum | cut -c1-7)`): now
  `{ shasum 2>/dev/null || sha1sum; }`. Both compute SHA-1, so the id is identical
  (e.g. 2.3 is `cdf64da` either way). Without the fallback a missing `shasum` gives an empty id
  and the build fails with an invalid tag `tiffingo:`.
- `t5/preflight.sh` (section "2. Ports"): if `lsof` is not installed, the port check uses
  `ss -ltnH "sport = :8080"`. Without it, a missing `lsof` makes a busy port look free.

Other things you might notice on Linux (no change needed):
- `preflight.sh` builds every release without a tag to fill the cache; these show as `<none>` images
  in `docker images`. They are only cache. `docker image prune` removes them.
- Timings are a bit slower than the slides: a full deploy took 10-14 s and a rollback 5-8 s here.
