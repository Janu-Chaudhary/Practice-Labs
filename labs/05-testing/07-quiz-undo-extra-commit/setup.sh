#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo
printf '__pycache__/\n.pytest_cache/\n' > .gitignore
cat > grade.py <<'EOF'
def letter(score):
    """80 or more is an A, 50 or more is a P (pass), anything lower is an F."""
    if score > 80:
        return "A"
    if score >= 50:
        return "P"
    return "F"
EOF
cat > test_grade.py <<'EOF'
from grade import letter


def test_high_score_is_a():
    assert letter(95) == "A"


def test_middle_score_is_pass():
    assert letter(60) == "P"


def test_low_score_is_fail():
    assert letter(10) == "F"
EOF
git add . && git commit -q -m "Add letter grades"
git rev-parse HEAD > .git/lab-base
printf '\n\ndef test_exactly_80_is_a():\n    assert letter(80) == "A"\n' >> test_grade.py
git add test_grade.py && git commit -q -m "Add failing test for score of exactly 80"
sed -i 's/score > 80/score >= 80/' grade.py
git add grade.py && git commit -q -m "Fix letter grade so 80 is an A"
git rev-parse HEAD > .git/lab-fix
printf 'TODO: ask tutor if 49.5 rounds up\nTODO: check P vs F for negative scores\n' > notes.txt
sed -i 's/^    if score >= 80:/    print("DEBUG score =", score)\n    if score >= 80:/' grade.py
git add notes.txt grade.py && git commit -q -m "wip"
banner "05-testing/07-quiz-undo-extra-commit"
