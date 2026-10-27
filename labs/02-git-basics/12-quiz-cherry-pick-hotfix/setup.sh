#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf 'def add(a, b):\n    return a + b\n\n\ndef divide(a, b):\n    return a / b\n' > calc.py
printf '# Calc\n' > README.md
git add . && git commit -q -m "Add calc"
git tag -a v1.0.0 -m "First release"
git switch -q -c feature
printf 'def power(a, b):\n    return a ** b\n' > power.py
git add power.py && git commit -q -m "Add power()"
printf 'def add(a, b):\n    return a + b\n\n\ndef divide(a, b):\n    if b == 0:\n        return None\n    return a / b\n' > calc.py
git add calc.py && git commit -q -m "Fix divide by zero"
mkdir -p docs && printf '# Usage\npower(2, 3) == 8\n' > docs/USAGE.md
git add docs && git commit -q -m "Document power()"
git switch -q main
printf '# Calc\n\nRun: python calc.py\n' > README.md
git add README.md && git commit -q -m "Explain how to run"
# remember the original tips (stored inside .git so they never show in git status)
git rev-parse feature > .git/lab-feature-tip
git rev-parse v1.0.0^{commit} > .git/lab-v100
banner "Quiz-style: copy ONE commit from feature to main, then tag the release"
