#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf 'def greet(name):\n    return f"Hello, {name}!"\n' > greet.py
printf 'PORT = 8000\nDEBUG = False\n' > config.py
git add . && git commit -q -m "Add greet and config"
git switch -q -c feature
printf 'def greet(name):\n    return f"Hi, {name}."\n' > greet.py
printf 'PORT = 9000\nDEBUG = False\n' > config.py
mkdir -p docs && printf '# Usage\nRun: python greet.py\n' > docs/USAGE.md
git add . && git commit -q -m "Rework greeting, move port, add docs"
git switch -q main
printf 'def greet(name):\n    return f"Hello, {name}! Good to see you."\n' > greet.py
printf 'PORT = 8080\nDEBUG = False\n' > config.py
git add . && git commit -q -m "Warmer greeting, port 8080"
banner "Twist: conflict in two files + a new file from feature"
