# Solution - 02-run-publish

```bash
docker run -d --name greeter-web -p 127.0.0.1:8081:3000 -e GREETING=Hola greeter:1.0
docker ps                                  # PORTS: 127.0.0.1:8081->3000/tcp
curl http://127.0.0.1:8081/                # Hola from greeter
```
- `-d` detached: runs in the background and prints the container id.
- `--name greeter-web` so later commands can use a name instead of an id.
- `-p 127.0.0.1:8081:3000`: host 127.0.0.1 port 8081 -> container port 3000. Without `127.0.0.1:`
  the port opens on every network interface (`0.0.0.0:8081->3000/tcp`).
- `-e GREETING=Hola` sets an environment variable inside the container.

## Common wrong attempts
- `docker run -d greeter:1.0 --name greeter-web -p 8081:3000` -> options after the image become the
  container's **command**, replacing CMD. Node images hand them to `node`, so the container exits at
  once: `docker ps` is empty, `docker ps -a` shows `Exited (9)`, `docker logs` shows
  `node: bad option: --name`. (On alpine you'd get `exec: "--name": executable file not found in $PATH`.)
  Put every option before the image.
- `-p 3000:8081` -> backwards. PORTS shows `0.0.0.0:3000->8081/tcp`, nothing listens on 8081 inside.
- `-p 8081:3000` (no IP) -> works with curl but the check fails: it is published on `0.0.0.0`, not
  127.0.0.1 only.
- Running a second time with the same name -> `Conflict. The container name "/greeter-web" is already
  in use`. Fix: `docker rm -f greeter-web`, then run again.
- No `-d` -> the terminal is attached to the server logs. Ctrl+C stops it. Use `-d`.
