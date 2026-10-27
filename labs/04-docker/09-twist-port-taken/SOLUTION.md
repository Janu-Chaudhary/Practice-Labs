# Solution - 09-twist-port-taken

```bash
docker ps -a                       # orders-old Up 0.0.0.0:8090->3000/tcp ; orders Exited
docker run -d --name orders -p 8090:3000 -e ORDERS_REGION=eu orders:2.0
# docker: Error response from daemon: Conflict. The container name "/orders" is already in use ...
docker rm orders                   # the stopped leftover can go (rm works on stopped containers)
docker run -d --name orders -p 8090:3000 -e ORDERS_REGION=eu orders:2.0
# docker: Error response from daemon: failed to set up container networking: ...
#   Bind for 0.0.0.0:8090 failed: port is already allocated
docker ps -a                       # the failed run left a NEW "orders" in state Created!
docker stop orders-old             # frees port 8090, keeps the container (and its logs)
docker rm orders                   # remove the Created leftover from the failed run
docker run -d --name orders -p 8090:3000 -e ORDERS_REGION=eu orders:2.0
curl http://localhost:8090/        # orders 2.0 region=eu
docker logs orders-old             # still readable: stopped containers keep their logs
```
Alternative order that avoids the leftover: `docker stop orders-old` and `docker rm orders` first,
then one `docker run`.

Why: a host port can be published by only one running container at a time. A container name is
unique across **all** containers, running or stopped. `stop` frees the port but keeps the container;
`rm` frees the name.

## Common wrong attempts
- `docker rm -f orders-old` -> frees the port, but breaks the rule (the logs are gone).
- Using `-p 8091:3000` to dodge the conflict -> the service must be on 8090.
- Re-running after the port error without `docker rm orders` -> name conflict again, because the
  failed run created the container (status `Created`) before the port bind failed.
- `docker start orders` -> starts the OLD stopped v1 container, not v2.
