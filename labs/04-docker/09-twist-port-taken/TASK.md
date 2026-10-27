# 09 - Deploy v2 when the port and the name are taken (Twist)

**Context:** setup built two images, `orders:1.0` and `orders:2.0`, and left this mess behind
(look with `docker ps` and `docker ps -a`):
- `orders-old` - running `orders:1.0`, publishing host port **8090**.
- `orders` - an old **stopped** container from `orders:1.0`.

**Task:** run version 2 as the live service:
- container name `orders`, image `orders:2.0`, in the background,
- host port **8090** -> container port 3000,
- environment variable `ORDERS_REGION=eu`.

`curl http://localhost:8090/` must answer `orders 2.0 region=eu`.

**Stop rules:** the team wants to read `orders-old`'s logs later: **stop it, but don't remove it**.
The old stopped `orders` container is garbage; you may remove it.

**Hints**
- Just try the `docker run` first and read the errors. You should meet two different ones.
- After a failed `docker run`, check `docker ps -a`: did Docker leave something behind?

**What will be checked**
- `orders` runs `orders:2.0` on 8090 -> 3000 with `ORDERS_REGION=eu`
- `orders-old` still exists, from `orders:1.0`, and is stopped
- curl on 8090 answers `orders 2.0 region=eu`
