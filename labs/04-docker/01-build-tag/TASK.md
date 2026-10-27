# 01 - Build and tag an image (Drill)

**Context:** `work/` has a tiny app: `greeting.txt`, a `Dockerfile` and a second file `Dockerfile.dev`.
No image exists yet.

**Task** (run everything from inside `work/`):

1. Build an image from `Dockerfile` and tag it `hello-cli:1.0`.
2. Build a second image from `Dockerfile.dev` and tag it `hello-cli:dev`.
3. Run each image once so it prints its greeting, and make Docker delete the container
   automatically when it exits.
4. List your images to see both tags.

**Stop rules:** don't edit the Dockerfiles. Don't leave stopped containers behind.

**Hints**
- `docker build` needs to know **which folder** to send to the builder (the build context). You are
  standing in it.
- By default `docker build` reads the file called `Dockerfile`. Another flag picks a different file.
- If you see `ERROR: docker: 'docker buildx build' requires 1 argument`, read that message again: what is
  the 1 argument?

**What will be checked**
- image `hello-cli:1.0` exists and was built from `Dockerfile`
- image `hello-cli:dev` exists and was built from `Dockerfile.dev`
- no stopped containers from either image are left
