# Solution - 06-quiz-shop-api-order (Quiz 2 Q15)

Read the failure first:
```bash
cd work
docker build -t shop-api:1.0 .
# npm error The `npm ci` command can only install with an existing package-lock.json ...
# ERROR: failed to build: ... process "/bin/sh -c npm ci" did not complete successfully: exit code: 1
```
`RUN npm ci` runs before anything was copied into `/app`, so there is no package-lock.json yet.

Fixed Dockerfile (edit with `code Dockerfile`, only move lines):
```dockerfile
FROM node:24-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```
```bash
docker build -t shop-api:1.0 .
docker image ls shop-api            # shop-api 1.0 ...
docker history shop-api:1.0         # newest first: CMD, EXPOSE, COPY . ., RUN npm ci, COPY package..., WORKDIR
```
Why this order:
1. `COPY package.json package-lock.json ./` first: `npm ci` needs the lockfile.
2. `RUN npm ci` next: its inputs are only the two manifest files. Editing server.js doesn't change
   them, so this layer comes from the cache.
3. `COPY . .` last: server.js changes only invalidate this step and the ones after it.

Bonus check of the cache:
```bash
echo 'console.log("shop-api v2")' > server.js
docker build -t shop-api:1.0 .      # WORKDIR, COPY package*, RUN npm ci -> CACHED ; COPY . . reruns
```

## Common wrong attempts
- Putting `COPY . .` before `RUN npm ci` and deleting the package COPY -> builds, but every
  server.js edit reruns npm ci (and you removed a line: "only reorder").
- Moving `COPY package...` after `RUN npm ci` -> same npm ci error as before.
- `docker run shop-api:1.0` to "test" -> the task says don't run a container.
- Forgetting the `.` at the end of `docker build` -> `'docker buildx build' requires 1 argument`.
