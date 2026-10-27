# Solution - 05-quiz-counter (Quiz 2 Q14)

```bash
cd work
docker build -t counter:1.0 .            # "." = build context: Dockerfile + files to COPY live here
docker volume create counter-data        # Docker-managed storage, lives independent of containers
docker run -d --name counter -p 8080:3000 -v counter-data:/data counter:1.0
docker ps                                # STATUS Up..., PORTS 0.0.0.0:8080->3000/tcp
curl http://localhost:8080/              # count=1
curl http://localhost:8080/              # count=2
docker exec counter cat /data/count.txt  # 2 (stored in the volume)
```
Equivalent long mount form:
`docker run -d --name counter -p 8080:3000 --mount type=volume,src=counter-data,dst=/data counter:1.0`

## Common wrong attempts
- `docker build -t counter:1.0` (no `.`) -> `ERROR: docker: 'docker buildx build' requires 1 argument`
  This is the mark that was lost in the quiz. The `.` tells Docker which folder to send as build context.
- `docker run -d counter:1.0 -p 8080:3000 -v counter-data:/data` -> everything after the image becomes the
  command (replacing `node server.js`). The node image runs `node -p 8080:3000 -v counter-data:/data`,
  which just prints the Node version and exits: `docker ps` shows nothing, `docker ps -a` shows
  `Exited (0)`, `docker logs <id>` shows `v24.x.x`, and PORTS is empty. Put options before the image.
- `-p 3000:8080` -> reversed: PORTS `0.0.0.0:3000->8080/tcp`, check fails.
- `-v counter-data:/data` typed as `-v /counter-data:/data` -> a leading `/` makes it a **bind mount** of
  the host folder /counter-data, not the volume.
- Skipping `docker volume create` -> `-v counter-data:/data` would auto-create it anyway, but create it
  explicitly as the task asks.
- `Bind for 0.0.0.0:8080 failed: port is already allocated` -> another container already holds 8080.
  `docker ps`, then `docker rm -f <that one>`, then run again.
- `Conflict. The container name "/counter" is already in use` -> an old (maybe Exited) container has
  that name. `docker rm -f counter` and re-run.
