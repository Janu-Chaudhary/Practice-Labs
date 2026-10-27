# 13 - Fast rebuilds, small context, clean tags (Twist)

**Context:** `work/` is the `shop` project. Setup built the old image `lab13-shop:1.0` from this Dockerfile:

```dockerfile
FROM node:24-alpine
LABEL course.lab=lab13
WORKDIR /app
COPY . .
RUN npm ci --omit=dev
EXPOSE 3000
CMD ["node", "server.js"]
```

The folder also holds things that must never go into an image: `logs/` (a 30 MB log file) and
`node_modules/` (installed on a laptop, with the wrong OS). There is no `.dockerignore`.
`server.js` has a line `const VERSION = "1.0";`.

Two complaints from the team: every tiny change to `server.js` reruns `npm ci`, and the image
contains the logs and the laptop's `node_modules`.

**Task:**

1. Change the Dockerfile so a change to only `server.js` does **not** rerun `npm ci`. Here you may
   add lines (unlike Quiz 2 Q15). Keep `LABEL course.lab=lab13`.
2. Create a `.dockerignore` so `logs` and `node_modules` (also `.git`, `.env`) never reach the build context.
3. Set `VERSION` in `server.js` to `"1.1"` and build `lab13-shop:1.1`.
4. Set `VERSION` to `"1.2"` and build `lab13-shop:1.2`, saving the **whole** build output (plain
   progress, one line per step) into `work/build-1.2.log`, while still seeing it on screen.
   The log must show that `RUN npm ci` came from the cache.
5. Tags: `lab13-shop:latest` must point to the same image as `1.2`; `lab13-shop:stable` (the last
   known-good) to the same image as `1.1`. Don't rebuild for this.
6. Delete the old tag `lab13-shop:1.0`.

**Stop rules:** don't change `package.json` / `package-lock.json`. Don't delete `logs/` or
`node_modules/` from the folder (ignore them instead). Don't leave containers behind (use `--rm` if
you test an image).

**Hints**
- Look at how lab 06 ordered the lines. A changed input invalidates that step **and every later step**.
- `docker build --progress=plain ...` prints one line per step, e.g. `#8 [4/5] RUN npm ci --omit=dev`
  then `#8 CACHED`.
- Build output goes to **stderr**. To send it through a pipe use `2>&1 |`. `tee FILE` writes to
  the file **and** the screen.
- `docker tag SOURCE TARGET` adds a name to an existing image; no rebuild. Compare the IMAGE ID
  column in `docker image ls lab13-shop`.
- Before `.dockerignore`, look at the `transferring context` line of a build. After, compare.

**What will be checked**
- `.dockerignore` lists `logs` and `node_modules`; `1.2` has no `/app/logs`, no host `node_modules`
- `1.1` and `1.2` exist with VERSION 1.1 / 1.2 in `/app/server.js`
- `1.2` was built with `COPY package...` -> `RUN npm ci` -> `COPY . .`
- `build-1.2.log` shows `RUN npm ci` as `CACHED` and `COPY . .` not cached
- `latest` = same image ID as `1.2`, `stable` = same image ID as `1.1`, `1.0` gone
- no containers left from these images
