# 02 - Restart policies: who brings it back? (Drill)

**Context:** one host, three containers' worth of work. Setup already built two images
(`lab72-api:1.0`, `lab72-jobs:1.0`) and started two containers:

- `lab72-api` - the web API. A teammate started it **without** a restart policy.
- `lab72-legacy` - an old service, started with `--restart always`. It is being retired.

The four policies: `no` (default), `on-failure` (only when the exit code is not 0),
`always`, `unless-stopped` (like always, but a container **you** stopped stays stopped).
A restart policy is a process supervisor for **one host**. It is not an orchestrator: if the
host dies, nothing moves the app anywhere.

**Task:**

1. Give `lab72-api` the policy `unless-stopped` **without recreating it** (it must stay the same container).
2. Simulate the demo's crash (Step 7, `pkill -9`): kill the node process inside it with
   `docker exec lab72-api pkill -9 node`. Then confirm with `docker ps` that Docker brought it back
   ("Up 2 seconds") and that its restart count went up.
3. Run the database-migration job: a container named `lab72-migrate` from `lab72-jobs:1.0`,
   in the background, with the named volume `lab72-state` mounted at `/state`.
   The job fails while the database is "not ready" (exit code 1) and exits 0 when it has applied
   the migrations. Choose the restart policy so that Docker **retries it when it fails** but
   **never runs it again after it succeeded**.
4. Retire `lab72-legacy`: stop it with `docker stop` and confirm it stays stopped even though its
   policy is `always`. Don't remove it.

**Stop rules:** don't recreate `lab72-api`. Don't use `docker kill` for step 2 (see hints).
Leave `lab72-api` running.

**Hints**
- `docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' NAME` shows a policy.
  `docker inspect -f '{{.RestartCount}}' NAME` shows how many times Docker restarted it.
- `docker update --help` - one flag changes the restart policy of an existing container.
- `docker kill` and `docker stop` count as "stopped by hand": Docker will not restart after them.
  A real crash is the process dying on its own, which is what `pkill -9` inside fakes.
- Watch the job: `docker ps -a --filter name=lab72-migrate` a few times, then `docker logs lab72-migrate`.
- Wrong policy on the job? `docker rm -f lab72-migrate` and `docker volume rm lab72-state`, then run it again.

**What will be checked**
- `lab72-api`: same container (still has `--init`), policy `unless-stopped`, running, RestartCount >= 1
- `lab72-migrate`: from `lab72-jobs:1.0`, volume `lab72-state` on `/state`, policy `on-failure`,
  status exited with code 0 after at least 2 restarts
- `lab72-legacy`: still exists and is stopped
