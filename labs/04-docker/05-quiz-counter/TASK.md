# 05 - Counter service: build, volume, run (Quiz-style, recreates Quiz 2 Q14)

**Context:** your folder (`work/`) has a Dockerfile for a small counter service (plus `server.js`,
`package.json`, `package-lock.json`, `.dockerignore`). No image, volume or container exists yet.

**Task:**

1. Build an image from the Dockerfile and tag it `counter:1.0`.
2. Create a volume named `counter-data`.
3. Start a container from `counter:1.0` in the background. Publish host port **8080** to container
   port **3000**, and mount `counter-data` at `/data`.

**Note:** use `docker ps` to check the container is running and its ports.
Then try `curl http://localhost:8080/` twice (count goes up) and `curl http://localhost:8080/health`.

**Done when:** the container is running. **Don't stop or remove it.**

**Hints**
- This is exactly the task the quiz gave. The build line needs three parts: command, tag, context.
- You may name the container (e.g. `--name counter`); the check finds it by its image.

**What will be checked** (same as the quiz)
- image `counter:1.0` was built
- volume `counter-data` exists
- a container from `counter:1.0` publishes port 8080 to 3000
- a container from `counter:1.0` mounts `counter-data` at `/data`
- (extra) `curl http://localhost:8080/health` answers `ok`
