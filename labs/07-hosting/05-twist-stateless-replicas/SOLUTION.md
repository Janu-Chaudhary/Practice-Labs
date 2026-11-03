# Solution - 05-twist-stateless-replicas

## 1. See the problem
```bash
cd work
curl -s http://127.0.0.1:8350/     # visits=1 served-by=3f2a...
curl -s http://127.0.0.1:8350/     # visits=1 served-by=9c71...   <- other replica, its own count
curl -s http://127.0.0.1:8350/     # visits=2 served-by=3f2a...
curl -s http://127.0.0.1:8350/     # visits=2 served-by=9c71...
```
(`served-by` is the container's hostname = its short ID.)

## 2. server.js: state out of the process
In the Files panel open `server.js`, make it read exactly this, Ctrl+S:
```js
const http = require("node:http");
const os = require("node:os");
const fs = require("node:fs");

const FILE = "/data/visits.txt"; // shared by every replica through the named volume

function readVisits() {
  try {
    return Number(fs.readFileSync(FILE, "utf8")) || 0;
  } catch {
    return 0; // no file yet = no visits yet
  }
}

http.createServer((req, res) => {
  if (req.url === "/healthz") return res.end("ok\n");
  if (req.url !== "/") { res.statusCode = 404; return res.end("not found\n"); }
  const visits = readVisits() + 1;
  fs.writeFileSync(FILE, String(visits));
  res.end(`visits=${visits} served-by=${os.hostname()}\n`);
}).listen(3000, "0.0.0.0", () => console.log("web listening on 3000"));
```
Why: the process now keeps **nothing** between requests. Any replica can answer any request, and a
replica can die or be replaced without losing data. That's what "stateless app server" means.

## 3-4. Build and replace both replicas
```bash
docker build -t lab75-web:1.1 .
docker rm -f lab75-web-1 lab75-web-2
docker run -d --name lab75-web-1 --network lab75-net -v lab75-data:/data lab75-web:1.1
docker run -d --name lab75-web-2 --network lab75-net -v lab75-data:/data lab75-web:1.1
```
Why: the code is inside the image, so a new image needs new containers. Both get the **same**
`-v lab75-data:/data`, so they read and write the same file. No `-p`: only the load balancer is
the public door; the replicas are reached by name on `lab75-net`.

## 5. Point the load balancer at them and test
```bash
docker restart lab75-lb
curl -s http://127.0.0.1:8350/     # visits=1 served-by=a1b2...
curl -s http://127.0.0.1:8350/     # visits=2 served-by=c3d4...
curl -s http://127.0.0.1:8350/     # visits=3 served-by=a1b2...
```
Why restart: nginx resolved `lab75-web-1/2` to IP addresses when it started. The new containers
may have new addresses; a restart makes it look the names up again (service discovery, by hand).

## Common wrong attempts
- Only `docker restart lab75-web-1 lab75-web-2` -> counts reset to 0 (memory is lost), still
  inconsistent. Restart does not load a new image either.
- `-v /data` or `-v data:/data` on one replica and something else on the other -> two different
  stores, still two answers. Both need the same volume **name**.
- Forgetting `-v` on a replica -> `/data` doesn't exist in it: the first request to it crashes the
  process (`ENOENT ... /data/visits.txt`), nginx returns 502 for that turn.
- Forgetting `--network lab75-net` -> nginx can't find the name; `docker restart lab75-lb` fails
  (`host not found in upstream "lab75-web-1:3000"` in `docker logs lab75-lb`).
- Adding `-p 3000:3000` to both replicas -> the second fails: `port is already allocated`.
  Fixed host ports are also why `docker compose up --scale` fails when the service has `ports:`.
- Sticky sessions on the load balancer would *hide* the problem for one user, but the state still
  dies with the replica. The fix is shared state, not stickiness.
- Note: read-add-write on a file is not safe under real concurrency (two replicas at the same
  moment can both write the same number). Production uses Postgres or Redis with an atomic update
  (`UPDATE counters SET n = n + 1`, `INCR visits`). The idea is the same: state outside the process.
