# Solution - 01-run-like-demo-a

```bash
cd work
docker build -t lab71-hello:1.0 .
```
Why: `-t` names the image; the `.` is the build context (the folder whose files `COPY` can see).

In the Files panel click **+ New file**, name it `app.env`, make it read:
```
LOG_LEVEL=info
DATABASE_URL=postgres://app:s3cret@db.internal:5432/hello
```
Save with Ctrl+S. Why: config lives **outside** the image, on the server. Same image, new config.

```bash
docker run -d --name lab71-hello --restart unless-stopped -p 127.0.0.1:8301:3000 --env-file app.env lab71-hello:1.0
docker ps                                   # Up ...   127.0.0.1:8301->3000/tcp   lab71-hello
curl http://127.0.0.1:8301/                 # hello-api log=info db=set
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' lab71-hello   # unless-stopped
docker port lab71-hello                     # 3000/tcp -> 127.0.0.1:8301
```
Each flag:
- `-d` detached: run in the background, give the terminal back.
- `--name lab71-hello` a fixed name, so `docker logs/rm/inspect lab71-hello` work.
- `--restart unless-stopped` Docker restarts it after a crash and after a Docker/host restart,
  but leaves it stopped if **you** ran `docker stop`.
- `-p 127.0.0.1:8301:3000` = `HOST_IP:HOST_PORT:CONTAINER_PORT`. With the IP, only this machine
  can connect. Without it (`-p 8301:3000`) Docker binds `0.0.0.0` = every network interface = public.
- `--env-file app.env` reads every `KEY=value` line of the host file into the container's environment.
- `lab71-hello:1.0` the image. It comes after all options (only an optional command may follow it).

## Common wrong attempts
- `-p 8301:3000` -> curl works, but `docker port` shows `0.0.0.0:8301` (public). Check fails.
  Fix: `docker rm -f lab71-hello` and run again with `127.0.0.1:` in front.
- `-p 127.0.0.1:3000:8301` -> host and container ports swapped. The host side is always first.
- `--restart always` -> also restarts after a crash, but a container you stopped by hand comes back
  when the Docker daemon restarts. "Not if you stop it by hand" = `unless-stopped`.
  (A wrong policy is the one thing you can fix in place: `docker update --restart unless-stopped lab71-hello`.)
- `--env-file app.env` written **after** the image -> Docker tries to run `--env-file` as the command.
- No env file -> `Exited (1)`, `docker logs lab71-hello` says `FATAL: DATABASE_URL and LOG_LEVEL must be set`.
- Changing `app.env` and running `docker restart lab71-hello` -> the old values stay. Env is fixed
  when the container is **created**: `docker rm -f` and `docker run` again (that's what the demo does).
- `ENV DATABASE_URL=...` in the Dockerfile -> the password is inside the image for anyone who pulls it.
