# 06 - Fix the shop-api Dockerfile order (Quiz-style, recreates Quiz 2 Q15)

**Context:** `work/` has a small Node.js project:

```
.dockerignore      node_modules
Dockerfile         FROM node:24-alpine
                   WORKDIR /app
                   RUN npm ci
                   COPY package.json package-lock.json ./
                   COPY . .
                   EXPOSE 3000
                   CMD ["node", "server.js"]
package-lock.json  {"lockfileVersion": 3}
package.json       {"name": "shop-api", "version": "1.0.0"}
server.js          console.log("shop-api listening on 0.0.0.0:3000")
```
`docker build -t shop-api:1.0 .` fails right now. (The quiz used `node:24-slim`; here it is
`node:24-alpine` so it builds faster. Same idea.)

**Task:** fix the Dockerfile so the build succeeds, **such that a change only to server.js doesn't
run npm ci again**. Only reorder the lines. Build the image as `shop-api:1.0`.

**Done when:** the image `shop-api:1.0` exists and was built from the fixed Dockerfile.
**Don't run a container.**

**Hints**
- First run the broken build and read the error. What files exist in `/app` when `RUN npm ci` runs?
- Each instruction is a layer. A changed input invalidates that step **and every step after it**.
- Bonus (not checked): after the good build, change the text in server.js and build again. Which
  steps say `CACHED`?

**What will be checked** (same as the quiz)
- image `shop-api:1.0` was built
- it was built with `COPY package.json package-lock.json ./`, then `RUN npm ci`
- it was built with `RUN npm ci`, then `COPY . .`
- (extra) the Dockerfile has the same lines, only reordered; no container was run
