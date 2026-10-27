# 03 - Look inside a running container (Drill)

**Context:** setup started a container named `notes-api` for you. You don't know which host port it
uses, and some information exists only in its logs or only inside its filesystem.

**Task:** fill in `work/answers.txt`. Open it in the Files panel, type each value after its `=`,
and save with Ctrl+S. Use the terminal only for the docker commands that find the values.

```
port=<the HOST port that is published to container port 3000>
token=<the value printed after "startup token:" in the container's logs>
motd=<the content of /tmp/motd.txt INSIDE the container>
hostpid=<the PID that the container's main process (PID 1 inside) has on the HOST>
```

One value per line, no spaces, exactly like `port=49153`.

**Stop rules:** don't stop, restart or remove `notes-api` (the token changes on restart).

**Hints**
- `docker ps` -> PORTS column, or `docker port notes-api`.
- `docker logs notes-api`
- `docker exec notes-api <command>` runs a command inside the running container.
- Inside the container the server is PID 1 (try `docker exec notes-api ps`). On the host it has
  another number: `docker top notes-api` or `docker inspect -f '{{.State.Pid}}' notes-api`.

**What will be checked**
- each of the 4 answers matches the real container
- `notes-api` is still running
