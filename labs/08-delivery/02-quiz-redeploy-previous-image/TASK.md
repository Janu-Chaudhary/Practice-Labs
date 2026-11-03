# 02 - Friday 19:00: roll back by redeploying the previous image (Quiz-style)

```
$ docker ps
CONTAINER ID   IMAGE            ...   STATUS         PORTS                      NAMES
3b1f0c9d2a77   lab82-shop:2.4   ...   Up 2 minutes   127.0.0.1:8402->3000/tcp   lab82-web
```

**Context:** the pipeline built `lab82-shop:2.3` last week and `lab82-shop:2.4` today, and deployed
2.4 as the container `lab82-web`. Tests and the health check passed, yet some checkouts now fail.
The source is in `work/app/` (you won't need to change it).

**Task:**
1. Find the evidence: which requests fail, and with what error? (The container's own output.)
2. Roll back **by redeploying the previous image**: `lab82-web` must run `lab82-shop:2.3`, with the
   **same container name, the same port and the same environment variables** as the 2.4 container had.
3. Prove it from inside the container: `/healthz` says version 2.3 and kabir's group order answers `ok`.

**Stop rules:** don't rebuild any image, don't edit the code, don't delete the `lab82-shop:2.4` image
(the developers need it to reproduce the bug). There is no `curl` in this terminal.

**Hints**
- `docker logs NAME` shows what the app printed, including errors.
- A container's settings are fixed when it is created. Read them first:
  `docker inspect lab82-web` (look at `Config.Env` and `HostConfig.PortBindings`), or more targeted
  `docker inspect -f '{{.Config.Env}}' lab82-web` and `docker port lab82-web`.
- The name and the host port stay taken until the old container is removed.
- Without curl, ask from inside: `docker exec lab82-web wget -qO- http://localhost:3000/healthz`
  (busybox `wget` is in the image; quote URLs that contain `&`).

**What will be checked**
- `lab82-web` is running from `lab82-shop:2.3`, host port 8402 -> 3000, env `STORE=pune`
- `/healthz` reports `"version":"2.3","store":"pune"`; kabir's group order answers `ok`
- nothing runs from `lab82-shop:2.4`, but that image still exists
- both images are exactly the ones the pipeline built (no rebuild)
