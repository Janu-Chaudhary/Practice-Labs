# Terminal practice pack

Hands-on practice for the terminal tasks in the Creative Problem Solving quizzes.

## Get it
```
git clone https://github.com/Janu-Chaudhary/Practice-Labs.git
cd Practice-Labs
```
You need `bash`, `git`, `python3` and Docker (for Topics 4 and 6). On Windows, use WSL. All commands below run from the `Practice-Labs` folder.

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
| `start-lab-tool.sh`, `lab-tool/` | The browser tool: task, file panel, real terminal, Check button |
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
