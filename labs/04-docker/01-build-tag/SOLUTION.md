# Solution - 01-build-tag

```bash
cd work
docker build -t hello-cli:1.0 .                     # -t name:tag, "." = build context = this folder
docker build -t hello-cli:dev -f Dockerfile.dev .   # -f picks the Dockerfile; context is still "."
docker run --rm hello-cli:1.0                       # --rm deletes the container when it exits
docker run --rm hello-cli:dev                       # prints mode=dev, then the greeting
docker image ls hello-cli                           # both tags listed
```

Why the `.`: the build context is the set of files the builder may `COPY`. `COPY greeting.txt ./`
copies from the context. With no context argument Docker can't start.

## Common wrong attempts
- `docker build -t hello-cli:1.0` (no dot) -> `ERROR: docker: 'docker buildx build' requires 1 argument`
- `docker build -f Dockerfile.dev -t hello-cli:dev` (no dot) -> same error. `-f` names the file, the
  `.` is still needed.
- `docker build -t hello-cli:dev Dockerfile.dev` -> Docker treats `Dockerfile.dev` as the context
  folder: `unable to prepare context: path "Dockerfile.dev" not found` / "not a directory".
- `docker run hello-cli:1.0` without `--rm` -> works, but leaves an Exited container. Fix:
  `docker ps -a` then `docker rm <name>`.
- `docker build -t Hello-CLI:1.0 .` -> `invalid tag "Hello-CLI:1.0": repository name must be lowercase`.
