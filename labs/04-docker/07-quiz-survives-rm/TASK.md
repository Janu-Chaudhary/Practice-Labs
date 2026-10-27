# 07 - What survives stop, start and rm? (Quiz-style)

**Context:** setup built the image `tally:1.0` (same counter server as the lecture: every request to
`/` adds 1 to `/data/count.txt` and logs `request count=N`). No volume or container exists.

**Task:**

1. Create a volume named `tally-data`.
2. Start a container named `tally-web` from `tally:1.0` in the background:
   - host `127.0.0.1:8082` -> container port 3000,
   - mount `tally-data` at `/data` using the long `--mount` syntax,
   - limit it to **half a CPU** and **256 MB** of memory.
3. `curl http://127.0.0.1:8082/` three times (count=1, 2, 3).
4. Stop the container, start it again, and curl once. Predict the number first.
5. Remove the container (force), start a **new** one with exactly the same `docker run` command,
   and curl once. Predict the number first.
6. In `answers.txt`, fill `no_volume_count=` with the count you would get in step 5 if the
   container had **no** volume (just the number).

**Done when:** `tally-web` (the new one) is running and the volume says 5. Don't remove it.

**Hints**
- `--mount type=volume,src=NAME,dst=/path` (no spaces after commas).
- `--cpus=0.5 --memory=256m`. Over the CPU limit -> throttled (slower). Over memory -> may be killed.
- Up-arrow in the terminal brings back your last `docker run` line.

**What will be checked**
- volume `tally-data`; `tally-web` running from `tally:1.0` on `127.0.0.1:8082`, volume at `/data`
- CPU and memory limits set
- count.txt in the volume is 5, and the running `tally-web` is a new container
- your answer in `answers.txt`
