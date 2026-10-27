# Solution - 11-quiz-network-by-name

## 1. Why it fails
```bash
cd work
docker logs lab11-web          # web: cannot reach http://localhost:8119/stock: ECONNREFUSED
docker exec lab11-web wget -qO- http://lab11-api:3000/stock   # wget: bad address 'lab11-api:3000'
```
Each container has its **own network namespace**. Inside `lab11-web`, `localhost` is lab11-web
itself, and nothing listens on 8119 there. Port 8119 exists only on the **host**. And on the default
`bridge` network Docker gives no DNS for container names, so `lab11-api` is a "bad address".

## 2-4. Network + recreate both containers
```bash
docker network create lab11-net                 # user-defined bridge network, with DNS for names
docker rm -f lab11-api lab11-web                # ports/env/network are fixed at create time -> recreate
docker run -d --name lab11-api --network lab11-net lab11-api:1.0
docker run -d --name lab11-web --network lab11-net -p 127.0.0.1:8111:3000 \
  -e API_URL=http://lab11-api:3000 lab11-web:1.0
curl http://127.0.0.1:8111/                     # web sees bolt stock=42
```
- `--network lab11-net`: both containers join the same network; Docker's DNS resolves each
  container **name** to its IP on that network.
- No `-p` on the api: it is reachable from `lab11-web` (same network) but not from the host. Only the
  web container is published. `-p` is for host -> container; container -> container needs no `-p`.
- `http://lab11-api:3000`: the **container** port (3000). 8119 was a host port and is gone now.

## 5. Debug from inside
```bash
docker exec lab11-web wget -qO- http://lab11-api:3000/stock    # {"item":"bolt","stock":42}
docker exec -it lab11-web sh                                   # or a shell: try ping lab11-api, exit to leave
```

## 6. The api's IP on the network
```bash
docker network inspect lab11-net              # "Containers": lab11-api ... "IPv4Address": "172.21.0.2/16"
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' lab11-api   # 172.21.0.2
echo "api_ip=172.21.0.2" > answers.txt        # use YOUR number, without the /16
```
Why use the name and not the IP: the IP can change when the container is recreated; the name stays.

## Common wrong attempts
- `API_URL=http://localhost:3000` or `http://127.0.0.1:8119` -> localhost is the web container
  itself: `ECONNREFUSED`.
- `API_URL=http://lab11-api:8119` -> name resolves, but 8119 was a host port. Inside the network
  the api listens on 3000: `ECONNREFUSED`.
- Both containers on the default network (no `--network`) with `API_URL=http://lab11-api:3000` ->
  502 with `The operation was aborted due to timeout` (or `ENOTFOUND`); `wget` says `bad address`.
  The name lookup goes to the outside DNS, which has never heard of `lab11-api`: the default
  bridge has no container-name DNS.
- `docker network connect lab11-net lab11-api` (without recreating) -> names work, but the api still
  publishes `127.0.0.1:8119` (check fails: not internal only). And lab11-web still has the old
  `API_URL`; env can't be changed on an existing container.
- `docker run ... lab11-web:1.0 --network lab11-net` -> options after the image become the command.
- `docker restart lab11-web` after "changing" something -> restart keeps the old env and network.
- `api_ip=172.21.0.2/16` -> the check wants the address only, no `/16`.
- `docker network rm lab11-net` while containers use it -> `error ... has active endpoints`.
