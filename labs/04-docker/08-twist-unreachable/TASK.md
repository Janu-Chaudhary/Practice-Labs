# 08 - "It's Up, but curl gets nothing" (Twist)

**Context:** setup built `inventory:1.0` from the files in `work/` and started it:
```
docker run -d --name inventory -p 8083:3000 inventory:1.0
```
`docker ps` shows `inventory` Up with `0.0.0.0:8083->3000/tcp`, but
`curl http://localhost:8083/health` gets no answer.

**Task:**

1. Find the real cause (look at `docker logs inventory` and the source).
2. Fix the source, then build the fixed image as `inventory:1.1` (keep `inventory:1.0`).
3. Replace the running container: the container named `inventory` must run `inventory:1.1`,
   still on host port 8083 -> container port 3000.
4. Prove it: `curl http://localhost:8083/health` prints `ok`.

**Stop rules:** don't delete the image `inventory:1.0`. Don't change the host port.

**Hints**
- Inside a container, `127.0.0.1` is the **container's own** loopback. Traffic from a published
  port arrives on the container's network address.
- Adding `EXPOSE 3000` to the Dockerfile is a tempting answer. Does EXPOSE publish anything?
- A running container doesn't pick up a new image. You must create a new container.

**What will be checked**
- image `inventory:1.1` exists, `inventory:1.0` still exists
- container `inventory` runs `inventory:1.1` and publishes 8083 -> 3000
- `curl http://localhost:8083/health` answers `ok`
