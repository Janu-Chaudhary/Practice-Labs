# Solution - 03-inspect-running

```bash
docker ps                                   # PORTS: 127.0.0.1:49xxx->3000/tcp  -> port=49xxx
docker port notes-api                       # same info: 3000/tcp -> 127.0.0.1:49xxx
docker logs notes-api                       # "startup token: 1a2b3c4d" -> token=1a2b3c4d
docker exec notes-api cat /tmp/motd.txt     # e.g. maple-12345 -> motd=maple-12345
docker exec notes-api ps                    # PID 1 is "node server.js" (PID namespace)
docker top notes-api                        # same process, host PID in the PID column -> hostpid=
docker inspect -f '{{.State.Pid}}' notes-api   # same host PID, directly
```
In the Files panel open `answers.txt` and make it read (with YOUR values):
```
port=49153
token=1a2b3c4d
motd=maple-12345
hostpid=809000
```
Save with Ctrl+S. Why: the answers are just text; the skill here is the docker commands that find them.

Why two PIDs: a PID namespace gives the container its own numbering (it sees itself as PID 1).
The host sees the same process under an ordinary PID. Namespaces = what you can see.

## Common wrong attempts
- `port=3000` -> that's the container port. The host port is the number left of `->`.
- `cat /tmp/motd.txt` on the host -> No such file: the container has its own filesystem view
  (mount namespace). Use `docker exec`.
- `hostpid=1` -> 1 is the PID inside the container, not on the host.
- `docker exec -it notes-api sh` also works: you get a shell inside; type `exit` to leave
  (the container keeps running because sh was not PID 1).
