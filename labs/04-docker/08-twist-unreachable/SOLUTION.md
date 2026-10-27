# Solution - 08-twist-unreachable

```bash
cd work
curl http://localhost:8083/health   # curl: (52) Empty reply from server   (sometimes: (56) Connection reset by peer)
docker ps                           # inventory Up, 0.0.0.0:8083->3000/tcp  -> publishing is fine
docker logs inventory               # inventory listening on 127.0.0.1:3000  <- the cause
code server.js                      # change  const HOST = "127.0.0.1";  to  const HOST = "0.0.0.0";
docker build -t inventory:1.1 .     # new image with the fix
docker rm -f inventory              # old container must go (the name and port 8083 are taken)
docker run -d --name inventory -p 8083:3000 inventory:1.1
curl http://localhost:8083/health   # ok
```
Why: the container has its own network namespace. Docker forwards host:8083 to the container's own
IP (e.g. 172.17.0.2):3000. A server bound to 127.0.0.1 only accepts connections from inside the
same container, so the forwarded traffic is refused. `0.0.0.0` = listen on every interface.

Prove it from inside: `docker exec inventory wget -qO- http://127.0.0.1:3000/health` prints `ok` even
in the broken version - the server works, it just isn't reachable from outside.

## Common wrong attempts
- Adding `EXPOSE 3000` and rebuilding -> no change. EXPOSE only documents a port; `-p` publishes.
- Rebuilding as `inventory:1.1` but not recreating the container -> the old container still runs 1.0.
- `docker run ... inventory:1.1` without removing the old one -> `Conflict. The container name
  "/inventory" is already in use` (and port 8083 `is already allocated`).
- `docker restart inventory` -> restarts the same container from the same old image.
- `-p 8083:3000` changed to `-p 127.0.0.1:8083:3000` -> that limits the **host** side; it doesn't fix
  the server binding inside the container.
