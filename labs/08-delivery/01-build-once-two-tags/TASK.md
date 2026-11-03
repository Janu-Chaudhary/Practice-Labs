# 01 - Build once, tag with the version AND the commit id (Drill)

```
$ git log --oneline
6c1d2e0 (HEAD -> main) Add dockerignore
91b7a44 TiffinGo 2.3

$ git status --short
 M server.js
```

**Context:** `work/` is the TiffinGo shop (a git repo). You added `"veg biryani": 160` to the
menu in `server.js` but have not committed it. The `Dockerfile` takes the release number as a
build argument (`ARG RELEASE`), which ends up in the image as `ENV RELEASE=...`.

The lecture rule: **build the image once, tag it with the commit id, promote the same image.**
A tag like `2.4` is for humans; the commit id tells you exactly which code is inside.

**Task** (inside `work/`):
1. Commit your change with the message `Add veg biryani to menu`.
2. Build **one** image from the Dockerfile with `RELEASE=2.4`, tagged **both**
   `lab81-shop:2.4` and `lab81-shop:<short commit id of HEAD>` (the id `git rev-parse --short HEAD` prints).
3. Show that both tags have the same IMAGE ID.

**Stop rules:** don't edit the Dockerfile. Don't create any other `lab81-shop` tags.

**Hints**
- `git rev-parse --short HEAD` prints the short commit id. `$(...)` puts a command's output into
  another command.
- `docker build` accepts `-t` more than once. A value for `ARG` is passed with `--build-arg NAME=value`.
- Order matters: if you build before committing, the "commit id" tag names the **old** commit.
- Got a wrong tag? `docker image rm lab81-shop:<wrongtag>` only removes that name (the image stays
  while another tag points to it).

**What will be checked**
- main has 3 commits, the last is `Add veg biryani to menu`, working tree clean
- `lab81-shop:2.4` and `lab81-shop:<short HEAD id>` exist and have the **same** image id
- the image has `RELEASE=2.4` and contains the biryani code
- no other `lab81-shop` tags
