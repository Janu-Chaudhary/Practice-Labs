# 11 - Two containers, one network, call by name (Quiz-style, harder)

**Context:** setup built two images and a teammate started them like this:

```bash
docker run -d --name lab11-api -p 127.0.0.1:8119:3000 lab11-api:1.0
docker run -d --name lab11-web -p 127.0.0.1:8111:3000 -e API_URL=http://localhost:8119 lab11-web:1.0
```

- `lab11-api` answers `GET /stock` on port 3000 with `{"item":"bolt","stock":42}`.
- `lab11-web` listens on 3000. For every request it calls `$API_URL/stock` and prints
  `web sees bolt stock=42`, or a `502 ...` line if it can't reach the API.

`curl http://127.0.0.1:8119/stock` works from your laptop, but `curl http://127.0.0.1:8111/` answers
`502 web cannot reach API_URL=http://localhost:8119 (ECONNREFUSED)`.

**Task:**

1. Work out why (`docker logs lab11-web`, and think: whose `localhost` is it?).
2. Create a user-defined network named `lab11-net`.
3. The API must be **internal only**: run `lab11-api` (same name, image `lab11-api:1.0`) on
   `lab11-net` with **no** port published to the host.
4. Run `lab11-web` (same name, image `lab11-web:1.0`) on `lab11-net`, still on host
   `127.0.0.1:8111` -> 3000, with `API_URL` pointing at the API **by its container name**.
5. Debug from inside: run `wget -qO- http://lab11-api:3000/stock` inside `lab11-web`.
6. Fill `answers.txt`: `api_ip=` the IP address `lab11-api` has on `lab11-net` (e.g. `api_ip=172.20.0.2`).

**Stop rules:** don't rebuild or change the images or the source. Only the containers and the
network change. Host port of web stays 8111.

**Hints**
- Container names only resolve (Docker's built-in DNS) on a **user-defined** network, not on the
  default `bridge`.
- `docker network create`, `docker run --network NAME ...`, `docker network inspect NAME`.
- `docker network connect` can add a running container to a network, but it can't take away the
  published port of `lab11-api`. A container's ports and env are fixed when it is created.
- Containers talk to each other on the **container** port (3000), not on a host port.

**What will be checked**
- network `lab11-net` exists
- `lab11-api` runs `lab11-api:1.0`, is on `lab11-net`, publishes no port
- `lab11-web` runs `lab11-web:1.0`, is on `lab11-net`, `API_URL=http://lab11-api:3000`, `127.0.0.1:8111`
- `curl http://127.0.0.1:8111/` answers `web sees bolt stock=42`
- `api_ip=` in `answers.txt` is correct
