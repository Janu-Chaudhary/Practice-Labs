# 12 - The container that keeps dying (Twist)

**Context:** setup built `lab12-report:1.0` (source in `work/report-src/`) and ran:

```bash
docker run -d --name lab12-report -p 127.0.0.1:8112:3000 lab12-report:1.0
```

`docker run` printed an id, so it "worked"... but `docker ps` doesn't list it and
`curl http://127.0.0.1:8112/` fails. The ops team keeps the service's config **on the host** in
`work/config/settings.json`. They want to edit that file without rebuilding the image.

**Task:**

1. Find out why `lab12-report` is not running. Write the **exit code** of this first crash into
   `answers.txt` as `first_exit_code=<number>`.
2. Replace the container: same name, same image, same port, plus the host folder `work/config`
   mounted at `/config` as a **bind mount**, **read-only** (the app must not be able to change it).
3. It will still not stay up. Read the logs again and fix the problem **in the file on the host**,
   changing only what is broken (the title stays `Daily report`). Then get the **same** container
   running again (don't create a new one) and `curl` it: `report: Daily report`.
4. Ops now wants the title `Weekly report`. Change it in the host file, then make the **same**
   container serve it (the app reads the file only when it starts). `curl` must answer
   `report: Weekly report`.

**Stop rules:** don't edit `server.js`, don't rebuild the image, don't copy the file into the image.
After step 2 don't remove `lab12-report` again (its logs are the proof of steps 3 and 4).

**Hints**
- Edit `config/settings.json` and `answers.txt` in the Files panel and save with Ctrl+S. The file
  you see there is the host file that gets mounted.
- A container that exited is only in `docker ps -a`. Its STATUS shows `Exited (N)`; `docker logs`
  works on stopped containers too. `docker inspect -f '{{.State.ExitCode}}' NAME` gives just N.
- Bind mount = a host path on the left: `-v "$(pwd)/config":/config:ro`, or
  `--mount type=bind,src="$(pwd)"/config,dst=/config,readonly`. A left side without `/` would be
  a named volume instead.
- Mounts can't be added to an existing container: that's why step 2 needs `docker rm` first.
- `docker start` starts a stopped container again, `docker restart` stops + starts a running one.
  Both keep the same container (and its old logs).

**What will be checked**
- `first_exit_code=` is right
- `config/settings.json` is valid JSON with `"title": "Weekly report"`
- `lab12-report` runs `lab12-report:1.0` on `127.0.0.1:8112`, `work/config` bind-mounted read-only at `/config`
- curl answers `report: Weekly report`
- the same container's logs show it served `Daily report` and then `Weekly report`
