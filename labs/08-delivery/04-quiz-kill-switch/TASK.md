# 04 - Kill switch: turn a feature off without a deploy (Quiz-style)

```
$ docker ps
IMAGE            STATUS         PORTS                      NAMES
lab84-shop:2.5   Up 1 minute    127.0.0.1:8404->3000/tcp   lab84-web

$ cat flags/flags.json
{
  "group_order": { "rollout_percent": 100 },
  "new_menu": { "rollout_percent": 10 }
}
```

**Context:** release 2.5 ships the group-order code **behind a flag**. The flag values live outside
the image, in `work/flags/flags.json`, which is mounted into the container at `/flags`. The app
reads that file **on every request** and decides per user:
`ON if sha256("<flag>:<user>") % 100 < rollout_percent`.

This morning someone raised `group_order` to 100%. Now some customers' group orders crash.

**Task:**
1. Confirm the problem from the container's output.
2. Use the **kill switch**: set `group_order` to `0` so nobody gets the feature.
3. Product also asks you to widen the `new_menu` rollout from 10% to `50`.
4. Prove from inside the container that kabir's group order answers `ok` again, and that
   meena now has `new_menu`.

**Stop rules:** no deploy of any kind: don't rebuild, don't restart, stop or re-create `lab84-web`.
Don't change `server.js`. Keep both flags in the file.

**Hints**
- Edit `flags/flags.json` in the **Files panel** and save with **Ctrl+S**. It must stay valid JSON
  (double quotes, no trailing comma).
- `docker logs lab84-web` shows the crashing requests.
- `docker exec lab84-web cat /flags/flags.json` shows what the container sees: the same file.
- The app has a helper endpoint: `/flag?name=new_menu&user=meena`.
- No curl here: `docker exec lab84-web wget -qO- "http://localhost:3000/checkout?customer=kabir&group=1"`
  (quotes needed because of `&`).

**What will be checked**
- `flags.json` is valid JSON with exactly the two flags: `group_order` 0, `new_menu` 50
- `lab84-web` is the same container, never restarted, still running `lab84-shop:2.5`; no new image
- kabir's group order answers `ok ... single (v2.5)`; the app reports `new_menu` at 50 (meena ON)
