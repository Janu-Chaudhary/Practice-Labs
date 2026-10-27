# 04 - Named volume basics (Drill)

**Context:** nothing exists yet. You will use the small `alpine:3.24` image as a throw-away tool.

**Task:**

1. Create a volume named `notes-data`. List volumes and inspect it (where does Docker keep it?).
2. Run a one-shot container from `alpine:3.24` that mounts `notes-data` at `/data` and writes the
   line `first note` into `/data/notes.txt`. The container must delete itself when it exits.
3. Run a **second, new** one-shot container (same idea) that **appends** `second note` to the file.
4. Run a third one-shot container that prints the file, to prove the data outlived both containers.

**Stop rules:** no containers (running or stopped) may be left that use `notes-data`.

**Hints**
- Pattern: `docker run [options] IMAGE [command...]`. The command after the image replaces the
  image's default CMD.
- A redirect like `>` or `>>` must run **inside** the container, so wrap it: `sh -c '...'`.
  Otherwise your host shell does the redirect on your laptop.
- `>` overwrites, `>>` appends.

**What will be checked**
- volume `notes-data` exists
- `/data/notes.txt` in it is exactly two lines: `first note`, `second note`
- no container uses `notes-data` any more
