#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > validate.py <<'EOF'
def is_valid_length(password):
    """A password needs at least 8 characters."""
    return len(password) >= 8
EOF
cat > test_validate.py <<'EOF'
from validate import is_valid_length


def test_rejects_short_password():
    assert is_valid_length("abc") is False


def test_accepts_long_password():
    assert is_valid_length("correcthorsebattery") is True
EOF
cat > mutants.py <<'EOF'
"""Tiny mutation tester. Run:  python3 mutants.py
For each mutant it copies validate.py + test_validate.py to a temp folder, makes ONE small change
to validate.py, and runs pytest there. Tests go red -> mutant KILLED (good). Still green -> SURVIVED."""
import os, pathlib, shutil, subprocess, sys, tempfile

MUTANTS = [
    (">= 8", "> 8", "change >= to >"),
    (">= 8", ">= 7", "change the limit 8 to 7"),
    (">= 8", ">= 9", "change the limit 8 to 9"),
]
here = pathlib.Path(__file__).parent
source = (here / "validate.py").read_text()
survivors = 0
for old, new, what in MUTANTS:
    with tempfile.TemporaryDirectory() as d:
        shutil.copy(here / "test_validate.py", d)
        pathlib.Path(d, "validate.py").write_text(source.replace(old, new))
        r = subprocess.run([sys.executable, "-m", "pytest", "-q", "-p", "no:cacheprovider"],
                           cwd=d, capture_output=True, env=dict(os.environ, PYTHONDONTWRITEBYTECODE="1"))
    status = "KILLED  " if r.returncode == 1 else "SURVIVED"
    survivors += r.returncode != 1
    print(f"{status}  mutant: {what:28s} ({old!r} -> {new!r})")
print(f"\n{survivors} mutant(s) survived." if survivors else "\nAll mutants killed.")
sys.exit(1 if survivors else 0)
EOF
git add . && git commit -q -m "Add password length check with tests"
git rev-parse HEAD > .git/lab-base
cp mutants.py .git/lab-base.mutants   # pristine copy for the checker
banner "05-testing/09-twist-kill-the-mutant"
