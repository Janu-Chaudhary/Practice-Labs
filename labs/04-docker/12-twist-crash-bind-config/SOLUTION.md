# Solution - 12-twist-crash-bind-config

## 1. Why is it not running?
```bash
cd work
docker ps                                       # empty: it is not running
docker ps -a                                    # lab12-report  Exited (3) ...
docker logs lab12-report                        # FATAL: cannot read /config/settings.json (ENOENT). Mount your config folder at /config.
docker inspect -f '{{.State.ExitCode}}' lab12-report    # 3
```
In the Files panel open `answers.txt`, make it read
```
first_exit_code=3
```
and save with Ctrl+S.
`docker run -d` only reports that the container **started**. If the main process exits, the
container exits with it. `ps -a` + `logs` is the first move every time.

## 2. Recreate with a read-only bind mount
```bash
docker rm lab12-report                          # it's stopped, so plain rm works; frees the name
docker run -d --name lab12-report -p 127.0.0.1:8112:3000 \
  -v "$(pwd)/config":/config:ro lab12-report:1.0
docker ps -a                                    # Exited (4) again!
docker logs lab12-report                        # FATAL: /config/settings.json is not valid JSON:
                                                #   Expected double-quoted property name ... (line 4 column 1)
```
- `-v "$(pwd)/config":/config:ro`: left side starts with `/` -> **bind mount** of that host folder.
  `:ro` = read-only inside the container. Long form:
  `--mount type=bind,src="$(pwd)"/config,dst=/config,readonly`.
- `$(pwd)` because `-v` needs an absolute host path; quotes in case the path has spaces.
- Progress: the exit code changed from 3 (file missing) to 4 (file found but broken).

## 3. Fix the file on the host, start the same container
In the Files panel open `config/settings.json` and remove the comma after `"ops"` (JSON allows no
trailing comma), so it reads:
```json
{
  "title": "Daily report",
  "owner": "ops"
}
```
Save with Ctrl+S. Then:
```bash
docker start lab12-report        # same container, same mount, re-reads the file at start
curl http://127.0.0.1:8112/      # report: Daily report
```

## 4. Change the config, restart, no rebuild
In the Files panel open `config/settings.json` again, make it read
```json
{
  "title": "Weekly report",
  "owner": "ops"
}
```
and save with Ctrl+S. Then:
```bash
docker exec lab12-report cat /config/settings.json   # already shows Weekly: same folder, live view
curl http://127.0.0.1:8112/      # still "report: Daily report": the app read the file at start
docker restart lab12-report      # process starts again and reads the new file
curl http://127.0.0.1:8112/      # report: Weekly report
docker logs lab12-report         # the crash line, then title="Daily report", then title="Weekly report"
```
Bonus proof of `:ro`: `docker exec lab12-report sh -c 'echo x >> /config/settings.json'`
-> `can't create /config/settings.json: Read-only file system`.

Bind mount vs named volume: a bind mount shows a **host folder you choose** (great for config and
for live-editing code). A named volume is storage Docker manages (`/var/lib/docker/volumes/...`),
best for data like databases. Neither is part of the image; both survive `docker rm`.

## Common wrong attempts
- Writing `first_exit_code=0` or `1` -> read it from `Exited (3)` or `.State.ExitCode`.
- `-v config:/config` -> no `/` on the left, so Docker creates an **empty named volume** called
  `config`. The app still finds no file (exit 3). Check with `docker inspect`: Type `volume`.
  Clean it later with `docker volume rm config`.
- `-v ./config:/config` -> modern Docker accepts it as a bind mount, but it depends on the folder
  you are standing in; `$(pwd)/config` is clear and works everywhere.
- `docker run ... lab12-report:1.0 -v ...` -> options after the image become the command.
- `docker start lab12-report -v ...` / trying to "add" the mount to the old container -> mounts are
  fixed when a container is created. `rm` and `run` again.
- Fixing the JSON and then `docker rm` + `docker run` again -> works, but the logs of the new
  container lack the old lines and the task said to keep the same container.
- Changing the title and only curling (no restart) -> still `Daily report`: the file inside **is**
  updated, but the program read it only once at start.
- `docker stop` + `docker start` instead of `restart` -> also fine, same container.
- Mounting the single file (`-v "$(pwd)/config/settings.json":/config/settings.json`) and then
  editing it with an editor that saves to a new file -> the container keeps seeing the old file.
  Mount the folder.
