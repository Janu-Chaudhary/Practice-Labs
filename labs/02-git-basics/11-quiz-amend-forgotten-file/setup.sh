#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf 'def greet(name):\n    return f"Hello, {name}!"\n' > greet.py
printf -- '- write settings loader\n' > todo.txt
git add . && git commit -q -m "Add greet"
printf 'import json\n\ndef load():\n    with open("settings.json") as f:\n        return json.load(f)\n' > loader.py
git add loader.py && git commit -q -m "Add setings loader"
printf '{\n  "theme": "dark"\n}\n' > settings.json
printf -- '- write settings loader\n- ask Sam about the deploy (private!)\n' > todo.txt
git add todo.txt
banner "Quiz-style: amend the last commit (typo + forgotten file), keep a private edit out"
