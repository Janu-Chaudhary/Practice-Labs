# Solution - 01-build-once-two-tags

```bash
cd work
git status                                  # modified: server.js
git add server.js
git commit -m "Add veg biryani to menu"     # FIRST commit: the image must hold committed code
git rev-parse --short HEAD                  # e.g. 4e5f6a7  (yours differs)
docker build --build-arg RELEASE=2.4 -t lab81-shop:2.4 -t lab81-shop:$(git rev-parse --short HEAD) .
docker image ls lab81-shop                  # two rows, SAME "IMAGE ID"
```

Why each part:
- `git commit` before the build: the commit id tag must name the code that is in the image. Build
  first and the tag points at "Add dockerignore", which does not contain biryani.
- `--build-arg RELEASE=2.4`: fills `ARG RELEASE` in the Dockerfile; `ENV RELEASE=${RELEASE}` keeps
  it in the image, so the running app knows its version (`/healthz` shows it).
- `-t ... -t ...`: one build, two names for the **same** image. That is "build once": staging and
  production get byte-for-byte the same thing.
- `$(git rev-parse --short HEAD)`: the shell runs the git command first and pastes its output
  (e.g. `4e5f6a7`) into the build command.
- `.`: the build context (this folder). Without it: `'docker buildx build' requires 1 argument`.

Alternative that is also "build once": build with one tag, then add the second name:
```bash
docker build --build-arg RELEASE=2.4 -t lab81-shop:2.4 .
docker tag lab81-shop:2.4 lab81-shop:$(git rev-parse --short HEAD)
```
`docker tag` never builds; it only adds a name to an existing image id.

Check it:
```bash
docker image inspect -f '{{.Id}}' lab81-shop:2.4
docker image inspect -f '{{.Id}}' lab81-shop:$(git rev-parse --short HEAD)    # identical
docker run --rm lab81-shop:2.4 printenv RELEASE                              # 2.4
```

## Common wrong attempts
- Building before committing -> the commit-id tag is the old commit. Fix: commit, then
  `docker tag lab81-shop:2.4 lab81-shop:$(git rev-parse --short HEAD)` and
  `docker image rm lab81-shop:<old id>`.
- `git commit -m "Add veg biryani to menu"` without `git add` -> "no changes added to commit"
  (use `git add server.js` or `git commit -am ...`).
- Forgetting `--build-arg` -> `RELEASE` is empty inside the image; the check fails.
- `-t lab81-shop:HEAD` or `-t lab81-shop:git rev-parse --short HEAD` -> a literal tag / a syntax
  error. The command must be inside `$( )`.
- Building twice (once per tag) after changing a file -> two different image ids: you would ship
  something to production that was never tested in staging.
- Typing the full 40-character hash -> a different tag name than the short id the check expects.
