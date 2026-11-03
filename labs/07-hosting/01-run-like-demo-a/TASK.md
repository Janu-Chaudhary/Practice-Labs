# 01 - Run it like Demo A (Drill)

**Context:** this is the `hello-api` step of the T4L2 demo, on your own machine. `work/` has
`server.js` and a `Dockerfile`. The server listens on port **3000** inside the container and
**refuses to start** unless `DATABASE_URL` and `LOG_LEVEL` are set in its environment.
No image is built and no container is running.

In production a reverse proxy (Caddy) is the only public door, so the app's port must be
reachable **from this machine only**, never from the network.

**Task:**

1. Build the Dockerfile in the current folder as `lab71-hello:1.0`.
2. Create a file `app.env` in `work/` with exactly these two lines:
   ```
   LOG_LEVEL=info
   DATABASE_URL=postgres://app:s3cret@db.internal:5432/hello
   ```
3. Start **one** container from `lab71-hello:1.0`:
   - in the background, named `lab71-hello`
   - restarted automatically after a crash or a Docker/host restart, but **not** if you stop it by hand
   - host port `8301` -> container port `3000`, bound to the **loopback address only**
   - its settings read from `app.env` (one flag, not one `-e` per variable)

**Stop rules:** don't edit `server.js` or the `Dockerfile`. Don't put the password in the Dockerfile.
Leave the container running.

**Hints**
- Create `app.env` with **+ New file** in the Files panel, paste the two lines, Ctrl+S.
  No quotes around values: `--env-file` would keep them as part of the value.
- All `docker run` options go **before** the image name. Anything after the image is the command.
- If the container is not in `docker ps`, read `docker logs lab71-hello`, then
  `docker rm lab71-hello` before you try again (the name is taken).
- Test it: `curl http://127.0.0.1:8301/` (no curl? `docker exec lab71-hello wget -qO- http://127.0.0.1:3000/`).

**What will be checked**
- `app.env` holds the two lines; image `lab71-hello:1.0` exists and contains no `DATABASE_URL`
- container `lab71-hello` runs from `lab71-hello:1.0` with restart policy `unless-stopped`
- port 3000 is published on `127.0.0.1:8301` only
- the container's environment has `LOG_LEVEL` and `DATABASE_URL`
- `GET http://127.0.0.1:8301/` answers `hello-api log=info db=set`
