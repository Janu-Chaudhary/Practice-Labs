# Solution - 02-quiz-redeploy-previous-image

## 1. Evidence
```bash
cd work
docker ps                              # lab82-web  lab82-shop:2.4  127.0.0.1:8402->3000/tcp
docker logs lab82-web                  # ravi: ok ... (v2.4)   asha: ok ... Rs 540 group (v2.4)
                                       # ERROR  Cannot read properties of undefined (reading 'map')  (v2.4)
                                       #        request: /checkout?customer=kabir&group=1
                                       # kabir has no saved group, so his group order crashes
docker images lab82-shop               # 2.3 and 2.4 both exist: the old image is still here
```

## 2. Copy the old container's settings
```bash
docker inspect -f '{{.Config.Env}}' lab82-web      # [STORE=pune PATH=... NODE_VERSION=... RELEASE=2.4]
docker port lab82-web                              # 3000/tcp -> 127.0.0.1:8402
```
Only `STORE=pune` was given with `-e`; `PATH`, `NODE_VERSION`, `RELEASE` come from the image
itself (the 2.3 image brings its own `RELEASE=2.3`). Do NOT copy `RELEASE=2.4` with `-e`: that
would override the image and the app would claim to be 2.4.

## 3. Redeploy the previous image
```bash
docker rm -f lab82-web                                                     # frees the name AND port 8402
docker run -d --name lab82-web -p 127.0.0.1:8402:3000 -e STORE=pune lab82-shop:2.3
docker ps                                                                  # lab82-web  lab82-shop:2.3  Up
docker exec lab82-web wget -qO- http://localhost:3000/healthz              # {"status":"ok","version":"2.3","store":"pune"}
docker exec lab82-web wget -qO- "http://localhost:3000/checkout?customer=kabir&group=1"
                                                                           # ok  order #1  Rs 240  single  (v2.3)
docker images lab82-shop                                                   # 2.4 still there
```
Why this is the fastest way back (~1 minute on a real platform, seconds here): **nothing is
tested, built or migrated**. The 2.3 image already exists and was tested when it was built. You
only start a container from it. This works here because 2.4's database change (if any) was
additive, so old code still runs (see lab 06 for when it does not).

`docker stop lab82-web` + `docker rm lab82-web` is the same as `docker rm -f lab82-web`.

## Common wrong attempts
- `docker run ... lab82-shop:2.3` while the old one still exists -> `Conflict. The container name
  "/lab82-web" is already in use`. Remove the old container first.
- Using another name (`lab82-web-old`) or port (`-p 8403:3000`) to dodge the conflict -> the
  check wants the same name and port: load balancers and users know those.
- Forgetting `-e STORE=pune` -> `/healthz` says `"store":"main"`: you rolled back the code but
  changed the configuration. Always read `docker inspect` before you remove a container.
- `docker build --build-arg RELEASE=2.3 -t lab82-shop:2.3 app` -> a rebuild: slower and a
  **different** image id from the one that was tested. The point is to reuse the old image.
- `docker image rm lab82-shop:2.4` -> the task said keep it (and it fails anyway while a
  container, even a stopped one, uses it).
- `docker exec lab82-web wget -qO- http://localhost:3000/checkout?customer=kabir&group=1`
  without quotes -> the shell treats `&` as "run in background" and `group=1` as a separate
  command. Quote the URL.
- `docker exec ... wget` on kabir's group order **before** the rollback prints
  `server returned error: HTTP/1.1 500`: that is the bug, read the body in `docker logs`.
