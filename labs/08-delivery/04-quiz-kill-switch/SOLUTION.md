# Solution - 04-quiz-kill-switch

## 1. The problem
```bash
cd work
docker logs lab84-web
#   asha: ok     order #5  Rs 540  group  (v2.5)
#   ERROR  Cannot read properties of undefined (reading 'map')  (v2.5)  request: /checkout?customer=kabir&group=1
#   ERROR  ...  request: /checkout?customer=zoya&group=1
docker exec lab84-web wget -qO- "http://localhost:3000/flag?name=group_order&user=kabir"
#   group_order for kabir: bucket 36, rollout_percent 100 -> ON
```

## 2 + 3. Edit the flags (Files panel)
Open `flags/flags.json`, make it exactly this, save with **Ctrl+S**:
```json
{
  "group_order": { "rollout_percent": 0 },
  "new_menu": { "rollout_percent": 50 }
}
```

## 4. Prove it (no restart!)
```bash
docker exec lab84-web cat /flags/flags.json                  # the container already sees the new file
docker exec lab84-web wget -qO- "http://localhost:3000/checkout?customer=kabir&group=1"
#   ok     order #6  Rs 240  single  (v2.5)
docker exec lab84-web wget -qO- "http://localhost:3000/flag?name=new_menu&user=meena"
#   new_menu for meena: bucket 36, rollout_percent 50 -> ON
docker ps                                                     # STATUS still "Up N minutes": never restarted
```

Why this is the fastest of the three ways back (seconds): no test, no build, no migration, no
new container. The buggy code is still inside v2.5, but it is **not reached** because the `if`
around it now reads OFF. Everything else in v2.5 keeps running. That only works because:
- the flag value lives **outside the image** (a mounted file here; a DB row in the lecture demo),
- the app **reads it on every request** (no cache). If the app read the file only at start-up, you
  would need a restart, and that is a deploy-like event.

Order of the "three ways back", fastest first: **flag off (seconds)** -> **redeploy previous image
(~1 minute)** -> **revert the commit and run the pipeline (minutes)**.

Percentages: kabir's bucket for `group_order` is 36. At 100 every bucket (0-99) is below the line,
so everyone is ON. At 0 nobody is (no bucket is < 0). meena's `new_menu` bucket is 36: off at 10,
ON at 50. Raising the percentage only moves the line, so everyone who had `new_menu` at 10% still
has it at 50%.

## Common wrong attempts
- `docker restart lab84-web` "to be safe" -> not needed, and the check fails: the task said no
  restart. In production a restart drops in-flight requests.
- `docker rm -f` + `docker run` -> that is a redeploy (new container id).
- Rebuilding the image with a changed `server.js` -> a full deploy for something a flag does in
  seconds.
- Deleting the `group_order` line -> the app would treat a missing flag as OFF, but the check wants
  both flags (and deleting flags is how Knight Capital got a reused flag name).
- `"rollout_percent": "0"` (a string) or `0%` -> not the number 0. `0%` is not even JSON.
- Leaving a trailing comma after the last flag -> invalid JSON: **every** group request now fails
  to read the flags. Check with `docker exec lab84-web cat /flags/flags.json` and the logs.
- Typing `wget ...` on the host -> run it inside the container with `docker exec`.
