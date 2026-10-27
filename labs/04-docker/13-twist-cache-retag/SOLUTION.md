# Solution - 13-twist-cache-retag

## 1. Dockerfile for the cache
In the Files panel open `Dockerfile` and make it read:
```dockerfile
FROM node:24-alpine
LABEL course.lab=lab13
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```
Save with Ctrl+S.
Why: `RUN npm ci` now depends only on the two manifest files. Editing `server.js` changes only the
input of `COPY . .`, so only that step (and the ones after it) rerun. Before, `COPY . .` came first,
so **any** file change invalidated `COPY . .` and therefore `npm ci` after it.

## 2. .dockerignore
Click **+ New file** in the Files panel, type `.dockerignore`, and make it read:
```
logs
node_modules
.git
.env
```
Save with Ctrl+S.
Why: `COPY . .` copies the whole build context. Without the ignore file the 30 MB log and the
laptop's `node_modules` go into the image (and are sent to the builder on every build).
`node_modules` must be created by `npm ci` **inside** the image, for the image's OS.

## 3-4. Two builds, the second one logged
In the Files panel open `server.js` and change only the VERSION line, so it reads:
```js
const http = require("node:http");
const VERSION = "1.1";
http.createServer((req, res) => res.end(`shop ${VERSION}\n`))
  .listen(3000, "0.0.0.0", () => console.log(`shop ${VERSION} listening on 3000`));
```
Save with Ctrl+S. Then in the terminal (inside `work/`):
```bash
docker build -t lab13-shop:1.1 .     # first build with the new Dockerfile: npm ci runs once
```
Back in the editor, change that line to `const VERSION = "1.2";` and save with Ctrl+S. Then:
```bash
docker build --progress=plain -t lab13-shop:1.2 . 2>&1 | tee build-1.2.log
```
In the output / log:
```
#7 [3/5] COPY package.json package-lock.json ./
#7 CACHED
#8 [4/5] RUN npm ci --omit=dev
#8 CACHED                          <- npm ci came from the cache
#9 [5/5] COPY . .                  <- no CACHED line: server.js changed, so this reran
```
- `--progress=plain`: one text line per step (instead of the live-updating panel).
- `2>&1`: build output goes to stderr; this joins it into stdout so the pipe gets it.
- `| tee build-1.2.log`: writes to the file and still shows it on screen.

## 5. Tags without rebuilding
```bash
docker tag lab13-shop:1.2 lab13-shop:latest     # a second name for the 1.2 image
docker tag lab13-shop:1.1 lab13-shop:stable
docker image ls lab13-shop                      # latest has the same IMAGE ID as 1.2, stable as 1.1
```
A tag is only a **name pointing at an image ID**. Several tags can point at one image; no copy is made.

## 6. Remove the old tag
```bash
docker image rm lab13-shop:1.0                  # Untagged: lab13-shop:1.0 / Deleted: sha256:...
```
If another tag still pointed at the same image, `rm` would only print `Untagged:` and keep the image.
The image is deleted only when its last tag goes (and no container uses it).

Optional proof (no containers left behind):
```bash
docker run --rm lab13-shop:1.2 ls -a /app       # no logs, node_modules has no left-from-host
```

## Common wrong attempts
- `docker build ... | tee build-1.2.log` without `2>&1` -> the screen shows the build, but the file
  is empty (stderr skipped the pipe).
- `docker build ... > build-1.2.log` -> nothing on screen, and the file is empty for the same reason.
- Building 1.2 without `--progress=plain` in a terminal -> the fancy display, no `#8 CACHED` lines.
  (Piped into `tee`, Docker switches to plain on its own, but say it explicitly.)
- Keeping `COPY . .` before `RUN npm ci` and only adding the ignore file -> builds, but the log
  shows `RUN npm ci` without `CACHED`.
- Building 1.2 first and then 1.1 -> the log may still be right, but read the task order: the log
  must be of the 1.2 build after a server.js-only change.
- `docker build -t lab13-shop:latest .` instead of `docker tag` -> may give the same ID via cache,
  but it is a rebuild; `docker tag` is the tool for "another name for the same image".
- `docker tag lab13-shop:latest lab13-shop:1.2` -> backwards: SOURCE first, then the new name.
- `docker image rm lab13-shop` -> means `lab13-shop:latest`, not 1.0. Always give the tag.
- `docker run lab13-shop:1.2 ...` without `--rm` to test -> leaves a stopped container, and
  `docker image rm` of its image then fails with `image is being used by stopped container`.
- `rm -rf logs node_modules` -> works for this build but breaks the stop rule; the next developer
  has them again. `.dockerignore` is the lasting fix.
