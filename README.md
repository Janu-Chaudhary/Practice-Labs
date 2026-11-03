# Terminal practice pack

Hands-on labs, a theory quiz and study guides for the Creative Problem Solving quizzes.
Everything runs locally in a quiz-style browser tool: task, file editor, real terminal and a Check button.

## Get it
```
git clone https://github.com/Janu-Chaudhary/Practice-Labs.git
cd Practice-Labs
./start-lab-tool.sh
```
Open http://127.0.0.1:8765 (it opens by itself on Linux). Keep that terminal open; Ctrl+C stops it.
If it says `Address already in use`, the tool is already running: just open the link.

### What you need
- `bash`, `git`, `python3` (3.11+), `sqlite3` (only the checkers use it; you never type it)
- `pip install pytest ruff pyyaml`
- Docker, for the Docker, migrations (Flyway), hosting and delivery labs. The labs use these images; pull them once while you're online:
  ```
  docker pull node:24-alpine && docker pull alpine:3.24 && docker pull nginx:alpine && docker pull postgres:16-alpine && docker pull flyway/flyway:13.10.0
  ```
  The professor's T5 demos also use `node:22-alpine` and `caddy:2.8.4-alpine`; `demos/t5/preflight.sh` pulls them (see `demos/README.md`).

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
4. Docker labs: install Docker Desktop and turn on *Settings → Resources → WSL integration* for Ubuntu.

Clone inside Ubuntu (`~`), not in `C:\` or `/mnt/c`: a Windows checkout is slow there and can break line endings (`bash\r: No such file or directory`).

## How to prepare
1. **Theory quiz** — in the tool, click **🧠 Theory quiz**. **📌 This quiz** holds the current quiz's lectures (T4L1, T4L2, T5, T6); every older topic is there too.
   Click options or press A–H, Enter checks, the number strip jumps to any question, **Got wrong** redoes mistakes. Scores are saved in your browser.
2. **Labs** — pick a lab on the left. Edit files in the Files panel (**+ New file**, Ctrl+S), type only commands in the terminal, press **✓ Check** (Ctrl+Enter). **↺ Reset lab** starts over.
3. **Guide** — **📖 Guide & theory** opens `guide.html`: per topic a mental model, commands, traps, worked scenarios and a cheat sheet, plus the professor's T5 demos walkthrough.
4. **Study briefs** — `_build/study/` has slide-by-slide notes for T4L1, T4L2, T5, the T5 demos and T6.

## What's inside
| Path | What it is |
|---|---|
| `labs/01-shell` … `labs/06-migrations` | Topics T0–T3: shell, git, remotes, Docker, testing/CI, Flyway migrations |
| `labs/07-hosting` | T4: run like Demo A, restart policies, health vs readiness, module boundaries, stateless replicas |
| `labs/08-delivery` | T5: build once and tag, rollback by image or revert, feature flags and rollout, expand/contract |
| `labs/09-load` | T6: N+1 queries, composite index leading column, the last-seat race, pool sizing |
| `demos/t5/` | The professor's T5 lecture demos (pipeline + rollout); see `demos/README.md` and the guide's demos section |
| `guide.html`, `_build/` | The study guide and its source (`python3 _build/assemble.py` rebuilds it); the theory questions live in `_build/sections/98-theory.html` |
| `lab-tool/`, `start-lab-tool.sh` | The browser tool (works offline once the Docker images are pulled) |
| `labs/bin/flyway` | Runs Flyway through Docker. In your own terminal: `export PATH="$PWD/labs/bin:$PATH"` |

Each lab folder has `TASK.md`, `setup.sh`, `check.sh` and `SOLUTION.md`. Docker labs leave containers running after you pass; **↺ Reset lab** (or `./setup.sh`) clears them.

## Without the browser tool
```
cd labs/02-git-basics/05-quiz-fix-greeting
./setup.sh && cd work      # fresh scenario
# ...solve TASK.md...
../check.sh                # grade
cd .. && ./setup.sh        # start over
```
