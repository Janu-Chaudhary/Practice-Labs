# Terminal practice pack

Hands-on practice for the terminal tasks in the Creative Problem Solving quizzes.

## Get it
```
git clone https://github.com/Janu-Chaudhary/Practice-Labs.git
cd Practice-Labs
```
You need `bash`, `git`, `python3`, `sqlite3` (the migration checkers use it; you never type it), Docker (Topics 4 and 6) and `pip install pytest ruff pyyaml` (Topic 5). All commands below run from the `Practice-Labs` folder.

### On Windows: use WSL
The labs are bash scripts and the lab tool's terminal uses Linux-only Python modules (`pty`, `termios`), so they don't run in plain Windows. WSL gives you a real Ubuntu inside Windows:
1. PowerShell **as Administrator**: `wsl --install`, then restart.
2. Open **Ubuntu** from the Start menu and run:
   ```
   sudo apt update && sudo apt install -y git python3 python3-pip sqlite3
   pip install pytest ruff pyyaml --break-system-packages
   cd ~ && git clone https://github.com/Janu-Chaudhary/Practice-Labs.git
   cd Practice-Labs && ./start-lab-tool.sh
   ```
3. Open http://127.0.0.1:8765 in your normal Windows browser.
4. Docker/Flyway labs: install Docker Desktop and turn on *Settings → Resources → WSL integration* for Ubuntu.

Clone inside Ubuntu (`~`), not in `C:\` or `/mnt/c`: a Windows checkout is slow there and can break line endings (`bash\r: No such file or directory`).

## Start here
1. Open `guide.html` in your browser and read **Start here**. Do the one-time setup it lists.
2. Practise in the quiz-style browser tool:
   ```
   ./start-lab-tool.sh
   ```
   It serves http://127.0.0.1:8765 and opens it on Linux (on macOS/WSL, open that link yourself). Keep that terminal open; Ctrl+C stops it.

## What's inside
| Path | What it is |
|---|---|
| `guide.html` | Topic guides: mental models, commands, errors, traps, worked scenarios, cheat sheets |
| `start-lab-tool.sh`, `lab-tool/` | The browser tool, laid out like the quiz: task, Files panel (open, **+ New file**, Ctrl+S to save), real terminal, Check button |
| `labs/01-shell` … `labs/06-migrations` | The labs: each folder has `TASK.md`, `setup.sh`, `check.sh`, `SOLUTION.md` |
| `labs/bin/flyway` | Runs Flyway through Docker. For Topic 6 in your own terminal: `export PATH="$PWD/labs/bin:$PATH"` |
| `_build/` | Source of `guide.html`. Rebuild with `python3 _build/assemble.py` |

## Without the browser tool
```
cd labs/02-git-basics/05-quiz-fix-greeting
./setup.sh && cd work      # fresh scenario
# ...solve TASK.md...
../check.sh                # grade
cd .. && ./setup.sh        # start over
```
