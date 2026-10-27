#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
cat > users.py <<'EOF'
def clean_email(email):
    if "@" not in email:
        raise ValueError("email needs an @")
    if len(email) > 254:
        raise ValueError("email too long")
    return email.strip().lower()


def password_ok(pw):
    return len(pw) >= 8


def clean_name(name):
    return name.strip()
EOF
cat > test_users.py <<'EOF'
import pytest
from users import clean_email, password_ok, clean_name


def test_email_requires_at():
    with pytest.raises(ValueError):
        clean_email("no-at-sign.com")


def test_email_lowercased():
    assert clean_email("Ann@Example.COM") == "ann@example.com"


def test_email_max_length():
    with pytest.raises(ValueError):
        clean_email("a" * 250 + "@x.com")


def test_password_too_short():
    assert password_ok("abc") is False


def test_password_ok():
    assert password_ok("correcthorse") is True


def test_name_stripped():
    assert clean_name("  Ann ") == "Ann"
EOF
cat > conftest.py <<'EOF'
# Lab helper (do not edit): records which tests each pytest run executed, so ../check.sh can see it.
import pathlib

_ran = []


def pytest_runtest_logreport(report):
    if report.when == "call":
        _ran.append(report.nodeid.split("::")[-1])


def pytest_sessionfinish(session, exitstatus):
    log = pathlib.Path(__file__).parent / ".runs.log"
    with open(log, "a") as f:
        f.write(" ".join(sorted(_ran)) + "\n")
EOF
banner "05-testing/04-select-tests"
