# 05 - Two replicas, two different answers (Twist)

**Context:** traffic grew, so the team scaled **horizontally**: two replicas of the web app,
`lab75-web-1` and `lab75-web-2` (image `lab75-web:1.0`), behind an nginx load balancer `lab75-lb`
that sends requests to them in turn (round-robin). Everything is on network `lab75-net`;
only the load balancer is published, on `127.0.0.1:8350`.

`GET /` should count every visit to the site. Users report that the counter jumps back and forth:
```
visits=1 served-by=3f2a...
visits=1 served-by=9c71...
visits=2 served-by=3f2a...
visits=2 served-by=9c71...
```
Look at `server.js`: `let visits = 0` lives in the memory of **one process**. Each replica counts
only its own requests. If a replica restarts, its count is lost too. Horizontal scaling needs
**stateless** app servers: the state goes somewhere all replicas share (in the lecture: Postgres).
Here the shared store is a file on a **named volume**.

**Task:**

1. See the problem: send 4 requests to the load balancer and compare the answers.
2. Change `server.js` so the count is **stored in the file `/data/visits.txt`**: on each `GET /`
   read the number from the file (0 if the file doesn't exist yet), add 1, write it back, answer it.
   Keep the answer format `visits=N served-by=HOSTNAME`.
3. Build it as `lab75-web:1.1`.
4. Replace both replicas: same names (`lab75-web-1`, `lab75-web-2`), on `lab75-net`, from
   `lab75-web:1.1`, both with the **same** named volume `lab75-data` mounted at `/data`.
   No host ports for the replicas.
5. Make the load balancer pick up the new replicas, then send requests again: the count must go
   up by 1 on every request, whichever replica answers.

**Stop rules:** don't edit `lb/nginx.conf`. Don't remove or recreate `lab75-lb` (restarting it is fine).
Don't publish a host port on the replicas.

**Hints**
- Edit `server.js` in the Files panel, Ctrl+S. In Node: `const fs = require("node:fs")`,
  `fs.readFileSync(path, "utf8")` (throws if the file is missing, so wrap it in `try { } catch { }`),
  `fs.writeFileSync(path, String(n))`.
- Send requests: `curl -s http://127.0.0.1:8350/` (run it 4 times; arrow-up + Enter).
  No curl in your terminal? The nginx image has one: `docker exec lab75-lb curl -s http://127.0.0.1/`.
- A named volume is created by the first `docker run -v lab75-data:/data ...` that uses it.
- nginx looks up `lab75-web-1` / `lab75-web-2` only when it **starts**. After you recreate the
  replicas, `docker restart lab75-lb`. If it then won't stay up, `docker logs lab75-lb`:
  a replica name it can't find.

**What will be checked**
- `server.js` uses `/data`; image `lab75-web:1.1` exists
- `lab75-web-1` and `lab75-web-2` run `lab75-web:1.1` on `lab75-net` with volume `lab75-data` at `/data`
- `lab75-lb` runs on `127.0.0.1:8350`
- 6 requests through the load balancer: `visits=` goes up by exactly 1 each time, and both replicas answer
