# 12 - Run a health-check script: stdout, stderr and exit codes (Twist)

## Situation
The current folder has:
- `bin/healthcheck.sh` - a small script a teammate wrote. Read it first (`cat bin/healthcheck.sh`).
  It reads `config/services.conf` and prints `OK    name` on **stdout** (normal output) for each service that is up,
  and `ERROR name is down` on **stderr** (the error stream) for each one that is down. It **exits** with
  code `0` if every service is up and `1` if any is down. The file is **not executable** yet.
- `config/services.conf` - one `name=up|down` per line.
- `status.txt` - the team's status log, 2 lines that must be kept.

Every program has two output streams. Both show on your screen, but `>` only catches stdout (stream 1).
`2>` catches stderr (stream 2). There is no `reports` folder yet. Run everything from `work/`.

## Task
1. Make `bin/healthcheck.sh` executable, so `./bin/healthcheck.sh` runs it (try it before and after: before, you get `Permission denied`).
2. Run the script **once**, saving stdout to `reports/ok.txt` and stderr to `reports/errors.txt`
   (nothing should appear on the screen).
3. Run it again, saving **both** streams together into `reports/all.txt`, in the order they are printed.
4. Save the script's **exit code** (just the number) into `reports/exit-code.txt`.
5. Create `reports/summary.txt` with exactly one line `down: N`, where N comes from **counting the lines of
   `reports/errors.txt`** inside your command (use `$( )`; don't type the number).
6. In **one** command line: run the script (output thrown away into `/dev/null`) and then
   - if it succeeded, append `<today> all up` to `status.txt`,
   - otherwise append `<today> ALERT services down`,

   where `<today>` is today's date as `YYYY-MM-DD`, produced by `date +%F` inside your command (not typed).

## Stop
- Don't edit `bin/healthcheck.sh` or `config/services.conf` (only change the script's permission).
- Don't remove the 2 existing lines of `status.txt`, and add exactly one line to it.

## Hints
- `chmod +x FILE` adds the "execute" permission. `ls -l bin` shows it as `x` in `-rwxr-xr-x`.
- `cmd > out.txt 2> err.txt` splits the streams. `cmd > all.txt 2>&1` merges them: "send 2 to wherever 1 goes **now**".
  The order matters: `cmd 2>&1 > all.txt` sends stderr to the screen (where stdout pointed at that moment).
- `$?` holds the exit code of the **last** command. `echo $?` right after the script; any command in between replaces it.
- `$(command)` is replaced by that command's output: `echo "lines: $(wc -l < f)"`. Use **double** quotes; single quotes print it literally.
- `a && b` runs b only if a succeeded (exit 0). `a || b` runs b only if a failed.
  `a && b || c`: b on success, c on failure.
- `/dev/null` is a bin: anything written there disappears. `> /dev/null 2>&1` silences a command completely.

## What will be checked
- `bin/healthcheck.sh` is executable and its content is unchanged; `config/services.conf` unchanged
- `reports/ok.txt` has only the 3 OK lines, `reports/errors.txt` only the 2 ERROR lines
- `reports/all.txt` has all 5 lines in the script's order
- `reports/exit-code.txt` holds just `1`
- `reports/summary.txt` is exactly `down: 2`
- `status.txt` is the 2 old lines, then `<today's date> ALERT services down`
