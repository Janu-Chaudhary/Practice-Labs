# Solution - 02-restart-policies

## 1. Change the policy in place
```bash
cd work
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' lab72-api   # no
docker update --restart unless-stopped lab72-api
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' lab72-api   # unless-stopped
```
Why: `docker update` changes a few settings of an existing container (restart policy, CPU/memory
limits). Ports, env and volumes can't be changed this way; for those you must `rm -f` and `run` again.

## 2. Crash it and watch Docker bring it back
```bash
docker exec lab72-api pkill -9 node      # SIGKILL the app process, like the demo's sudo pkill -9
docker ps --filter name=lab72-api        # STATUS: Up 2 seconds  <- restarted
docker inspect -f '{{.RestartCount}}' lab72-api   # 1
docker logs lab72-api                    # two "api started" lines: one per start
```
Why: the process died without anyone running `docker stop`, so the policy applies.
With policy `no` (before step 1) the same `pkill` leaves it `Exited (137)` (137 = 128 + signal 9).

## 3. One-off job: on-failure
```bash
docker run -d --name lab72-migrate --restart on-failure -v lab72-state:/state lab72-jobs:1.0
docker ps -a --filter name=lab72-migrate  # Restarting (1) ... then: Exited (0)
docker logs lab72-migrate
#   attempt 1: database not ready yet
#   attempt 2: database not ready yet
#   attempt 3: applied 3 migrations
docker inspect -f '{{.State.Status}} {{.State.ExitCode}} {{.RestartCount}}' lab72-migrate   # exited 0 2
```
Why: `on-failure` restarts only after a non-zero exit code. Once the job exits 0 Docker leaves it
alone. (`--restart on-failure:5` would also cap the retries at 5.) The `-v lab72-state:/state`
named volume keeps the attempt counter across restarts.

## 4. docker stop is not undone
```bash
docker stop lab72-legacy
docker ps -a --filter name=lab72-legacy   # Exited (143) ... and it stays that way
```
Why: Docker remembers that **you** stopped it. Even `always` won't restart it now. The difference
between `always` and `unless-stopped` only shows when the Docker daemon (or host) restarts:
`always` starts it again then, `unless-stopped` doesn't.

## Common wrong attempts
- `docker rm -f lab72-api` + `docker run ... --restart unless-stopped` -> a new container without
  `--init`, and the task said "in place". Use `docker update`.
- `docker kill lab72-api` or `docker stop lab72-api` to "crash" it -> it stays `Exited`. That's a
  manual stop, not a crash. RestartCount stays 0.
- `docker restart lab72-api` -> also doesn't raise RestartCount (manual restart, not the policy).
- `--restart always` or `unless-stopped` on the job -> after success it runs again, and again
  (`attempt 4: already up to date`, `attempt 5...`): it never stays finished. Clean up with
  `docker rm -f lab72-migrate` and `docker volume rm lab72-state`.
- `--restart no` on the job -> attempt 1 fails, `Exited (1)`, nobody retries.
- `docker run ... lab72-jobs:1.0 --restart on-failure` -> flags after the image are the command.
- Thinking `unless-stopped` = high availability: it covers a process crash and a host reboot.
  If the VM is gone, nothing reschedules the app. That needs more hosts + an orchestrator.
