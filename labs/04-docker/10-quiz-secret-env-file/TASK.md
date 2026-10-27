# 10 - Get the password out of the image (Quiz-style, harder)

**Context:** a teammate containerised the `payments` service. `work/` has `server.js`,
`package.json`, `package-lock.json`, a `.env` file with the real database settings, and this Dockerfile:

```dockerfile
FROM node:24-alpine
WORKDIR /app
ENV DB_HOST=db.internal
ENV DB_PASSWORD=Summer2024!
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

There is **no** `.dockerignore`. Setup already built their image as `lab10-payments:1.0`.
Anyone who can pull that image can read the password **twice**: once in the image metadata, once
as a file. The server reads `DB_HOST` and `DB_PASSWORD` from the environment and exits if they are missing.

**Task:**

1. See the leak for yourself (not checked): find the password in `lab10-payments:1.0` with
   `docker history` / `docker image inspect`, and print the `.env` file that sits inside the image.
2. Fix the build: remove both `ENV DB_...` lines from the Dockerfile, and create a `.dockerignore`
   so `.env` (also `node_modules` and `.git`) never reaches the build context. Keep `COPY . .`.
3. Build the fixed image as `lab10-payments:1.1`.
4. Start a container named `lab10-payments` from `1.1` in the background, host `127.0.0.1:8110` ->
   container port 3000, and give it the settings **at run time from the `.env` file** (one flag, not
   one `-e` per variable).
5. `curl http://127.0.0.1:8110/health` must print `payments ok db=db.internal password=set`.
6. Delete the leaky tag `lab10-payments:1.0`.

**Stop rules:** don't edit `server.js` or `.env`. Don't put the password in the Dockerfile in any
form (`ENV`, `ARG`, `RUN echo ...`). Only `lab10-payments:1.1` may remain.

**Hints**
- Edit `Dockerfile` in the Files panel and save with Ctrl+S. Create `.dockerignore` with
  **+ New file** (one path per line). The terminal is only for the docker commands.
- `docker history --no-trunc IMAGE` shows the instruction behind every layer. `ENV` lines show up there.
- To read a file inside an image without starting the server: `docker run --rm IMAGE cat /app/.env`.
- `docker run --help | grep env` lists two flags. One reads a whole file of `KEY=value` lines.
- First try running 1.1 with **no** env flag and read `docker logs lab10-payments`. Why did it exit?
  (Then `docker rm lab10-payments` before you try again: the name is taken.)

**What will be checked**
- Dockerfile has no `DB_PASSWORD`, still has `COPY . .`; `.dockerignore` lists `.env`
- `lab10-payments:1.1`: password not in `docker image inspect`, not in `docker history`, no `/app/.env`
- `lab10-payments:1.0` no longer exists
- container `lab10-payments` runs `1.1` on `127.0.0.1:8110` with `DB_HOST` and `DB_PASSWORD` set
- curl on `/health` answers `payments ok db=db.internal password=set`
