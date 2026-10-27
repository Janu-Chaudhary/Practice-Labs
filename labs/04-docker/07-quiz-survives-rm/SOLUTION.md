# Solution - 07-quiz-survives-rm

```bash
docker volume create tally-data
docker run -d --name tally-web -p 127.0.0.1:8082:3000 \
  --mount type=volume,src=tally-data,dst=/data --cpus=0.5 --memory=256m tally:1.0
curl http://127.0.0.1:8082/      # count=1
curl http://127.0.0.1:8082/      # count=2
curl http://127.0.0.1:8082/      # count=3
docker stop tally-web            # process stops; container + writable layer kept (docker ps -a: Exited)
docker start tally-web           # same container again (ports/mounts/limits remembered)
curl http://127.0.0.1:8082/      # count=4
docker rm -f tally-web           # container and its writable layer deleted. The volume is NOT.
docker run -d --name tally-web -p 127.0.0.1:8082:3000 \
  --mount type=volume,src=tally-data,dst=/data --cpus=0.5 --memory=256m tally:1.0
curl http://127.0.0.1:8082/      # count=5  (new container, same volume)
docker logs tally-web            # listening on 3000 / request count=5  (a new container has new logs)
echo "no_volume_count=1" > answers.txt
```
Why `no_volume_count=1`: without a volume, `/data/count.txt` lives in the container's writable layer.
`docker rm` deletes that layer; a new container starts with an empty one, so the count starts again.

Summary: **stop/start** keeps everything (same container). **rm** deletes the container + writable layer.
A **named volume** has its own lifecycle and survives rm.

## Common wrong attempts
- `--mount type=volume, src=tally-data, dst=/data` (spaces) -> the shell splits it into separate words:
  `invalid argument "type=volume," for "--mount" flag: invalid field '' must be a key=value pair`.
- `--mount type=volume,source=tally-data,target=/data` is fine too (src/source, dst/target/destination).
- `docker run` again without removing first -> `Conflict. The container name "/tally-web" is already in use`.
- `docker restart` instead of rm + run -> count=5 too, but it is the same container (logs still show 1-4),
  so the "new container" check fails.
- `--memory=256` (no unit) -> bytes; Docker refuses: `Minimum memory limit allowed is 6MB`.
