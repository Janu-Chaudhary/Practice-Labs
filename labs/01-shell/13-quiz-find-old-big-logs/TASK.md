# 13 - Find old and big logs, archive them, back up the config (Quiz-style, 8 marks)

## Situation
The disk of the `project` server is filling up. Logs are spread over several sub-folders:
```
project/
  api/logs/      api.log  api-2026-09.log
  worker/logs/   worker.log  worker-2026-09.log
  web/           access.log
  docs/          logs-howto.md
  config/        app.yml  db.yml  secrets/.keep   (.keep is hidden: ls -la shows it)
```
Some logs are big, some haven't been modified for weeks. `ls -l` shows sizes and dates, but `find` can
search all sub-folders at once by **name**, **type**, **size** and **age**. There is no `reports`, `archive`
or `backup` folder yet. Run everything from `work/`.

## Task (in this order)
1. `reports/big-logs.txt`: the paths (starting with `project/`) of every **`.log` file** under `project`
   that is **bigger than 100 KB**, one per line, sorted with `sort`.
2. `reports/log-count.txt`: just the **number** of `.log` **files** under `project`.
3. Move every `.log` file under `project` that was **last modified more than 14 days ago** into a new folder
   `archive/` (directly inside it, keeping its name: `archive/access.log`, ...). The newer logs stay where they are.
4. Back up the whole `project/config` folder (with its sub-folder and hidden file) so that it becomes
   `backup/config/...` (`backup/config/app.yml`, `backup/config/secrets/.keep`, ...). The original stays.

## Stop
- Don't change any file's contents. Don't move or delete anything except the old logs in step 3.
- Do step 1 and 2 **before** step 3 (they describe the folder as it is at the start).

## Hints
- `find project -name '*.log'` = every file or folder under `project` whose name ends in `.log`. Quote the pattern.
- `-type f` = files only, `-type d` = folders only. Tests are joined with AND: `find project -type f -name '*.log'`.
- `-size +100k` = bigger than 100 KiB. `-mtime +14` = last modified **more than** 14 days ago (`-mtime -14` = within the last 14 days).
- See the dates: `ls -l project/*/logs project/web`.
- Acting on what find found: `find ... -exec mv {} archive/ \;` runs `mv FILE archive/` once per file
  (`{}` = the file, `\;` ends the command). Or let the shell paste the list in: `mv $(find ...) archive/`.
- Always run the `find` alone first and read its list before you add `-exec mv` or `-delete`.
- `cp -r SRC DEST/`: when DEST is an existing folder, SRC is copied **into** it under its own name.

## What will be checked
- `reports/big-logs.txt` is exactly the 2 big log paths, sorted
- `reports/log-count.txt` holds just `5`
- `archive/` holds exactly the 3 old logs, unchanged; they are gone from `project`; the 2 newer logs are untouched
- `backup/config/app.yml`, `backup/config/db.yml`, `backup/config/secrets/.keep` exist and match the originals
- `project/config` and `project/docs` are untouched
