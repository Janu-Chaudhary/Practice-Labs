# Solution - 04-volume-basics

```bash
docker volume create notes-data
docker volume ls                       # notes-data listed
docker volume inspect notes-data       # Mountpoint: /var/lib/docker/volumes/notes-data/_data
docker run --rm -v notes-data:/data alpine:3.24 sh -c 'echo "first note" > /data/notes.txt'
docker run --rm -v notes-data:/data alpine:3.24 sh -c 'echo "second note" >> /data/notes.txt'
docker run --rm -v notes-data:/data alpine:3.24 cat /data/notes.txt
```
- `-v notes-data:/data`: left side is a **name** (no `/`), so it is a named volume, not a host folder.
  Long form: `--mount type=volume,src=notes-data,dst=/data`.
- `--rm` deletes the container (and its writable layer) on exit. The volume is separate, so the file stays.
- `sh -c '...'` runs the whole string, including the redirect, inside the container.

## Common wrong attempts
- `docker run --rm -v notes-data:/data alpine:3.24 echo first note > /data/notes.txt` -> the `>` is
  done by **your host shell**: `bash: /data/notes.txt: No such file or directory` (or writes on the host).
- `docker run --rm alpine:3.24 -v notes-data:/data ...` -> `-v` is after the image, so Docker tries to
  run `-v` as a program: `exec: "-v": executable file not found`.
- `-v ./notes-data:/data` or `-v $(pwd)/data:/data` -> that is a **bind mount** of a host folder, not
  the named volume. The check reads the volume and finds nothing.
- Forgetting `--rm` -> exited containers stay and keep the volume "in use":
  `docker volume rm notes-data` would fail with `volume is in use`. Clean with `docker ps -a` + `docker rm`.
