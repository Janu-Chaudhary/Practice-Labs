#!/usr/bin/env bash
# Quiz-style (T4L1): a modular monolith where billing reaches into the users module's private table.
# Fix billing to use the users public API so the boundary check (a Packwerk-style pytest) passes; commit.
source "$(dirname "$0")/../../lib/common.sh"
fresh_work
git_repo .
mkdir -p shop/users shop/billing tests

cat > pytest.ini <<'INI'
[pytest]
pythonpath = .
testpaths = tests
addopts = -p no:cacheprovider
INI
printf '__pycache__/\n.pytest_cache/\n' > .gitignore

cat > shop/__init__.py <<'PY'
"""shop: ONE deployable, one process, split into modules (users, billing).
Rule: a module may only use another module through its PUBLIC API (the module's api.py).
Everything starting with an underscore is private to its module."""
PY

cat > shop/users/__init__.py <<'PY'
"""users module. Owns: user records and the rules about them (e.g. how an email is normalised).
Public API: shop.users.api   Private: shop.users._store (the users table)."""
PY

cat > shop/users/_store.py <<'PY'
# PRIVATE to the users module: the raw "users table" as it is stored.
# Emails are stored exactly as the user typed them. Only users/api.py knows the rules.
USERS_TABLE = {
    1: {"name": "Ana Silva", "email": "  Ana.Silva@Example.COM "},
    2: {"name": "Ben Okafor", "email": "ben@example.com"},
}
PY

cat > shop/users/api.py <<'PY'
"""PUBLIC API of the users module. Other modules call these functions, nothing else."""
from shop.users import _store


def get_email(user_id: int) -> str:
    """The user's email, normalised (trimmed, lower case). Raises KeyError for an unknown user."""
    return _store.USERS_TABLE[user_id]["email"].strip().lower()


def get_display_name(user_id: int) -> str:
    """The name to print on documents. Raises KeyError for an unknown user."""
    return _store.USERS_TABLE[user_id]["name"]
PY

cat > shop/billing/__init__.py <<'PY'
"""billing module. Owns: invoices. Uses the users module only through shop.users.api."""
PY

cat > shop/billing/invoice.py <<'PY'
from shop.users._store import USERS_TABLE


def build_invoice(user_id: int, amount_cents: int) -> dict:
    user = USERS_TABLE[user_id]
    return {
        "to": user["email"],
        "name": user["name"],
        "amount": f"{amount_cents / 100:.2f} EUR",
    }
PY

cat > tests/test_invoice.py <<'PY'
from shop.billing.invoice import build_invoice


def test_invoice_for_ana():
    assert build_invoice(1, 1250) == {
        "to": "ana.silva@example.com",
        "name": "Ana Silva",
        "amount": "12.50 EUR",
    }


def test_invoice_for_ben():
    assert build_invoice(2, 99)["to"] == "ben@example.com"
    assert build_invoice(2, 99)["amount"] == "0.99 EUR"
PY

cat > tests/test_boundaries.py <<'PY'
"""Module boundary check (like Shopify's Packwerk, run in CI).
billing may use the users module ONLY through its public API: shop.users.api
"""
import ast
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
PUBLIC_API = "shop.users.api"
PRIVATE_NAMES = {"_store", "USERS_TABLE"}


def find_violations():
    found = []
    for f in sorted((ROOT / "shop" / "billing").rglob("*.py")):
        rel = f.relative_to(ROOT)
        tree = ast.parse(f.read_text(), filename=str(f))
        for node in ast.walk(tree):
            if isinstance(node, ast.ImportFrom) and node.module:
                if node.module == "shop.users":
                    found += [f"{rel}:{node.lineno} imports shop.users.{a.name}"
                              for a in node.names if a.name != "api"]
                elif node.module.startswith("shop.users.") and node.module != PUBLIC_API:
                    found.append(f"{rel}:{node.lineno} imports {node.module}")
            elif isinstance(node, ast.Import):
                found += [f"{rel}:{node.lineno} imports {a.name}" for a in node.names
                          if a.name.startswith("shop.users.") and a.name != PUBLIC_API]
            elif isinstance(node, ast.Name) and node.id in PRIVATE_NAMES:
                found.append(f"{rel}:{node.lineno} uses {node.id}")
            elif isinstance(node, ast.Attribute) and node.attr in PRIVATE_NAMES:
                found.append(f"{rel}:{node.lineno} uses .{node.attr}")
    return found


def test_billing_uses_only_the_users_public_api():
    violations = find_violations()
    assert not violations, (
        "Dependency violation: billing -> users (not in users' public API "
        + PUBLIC_API + "):\n  " + "\n  ".join(violations)
    )
PY

git add -A
git commit -q -m "shop: users and billing modules"
banner "04-quiz-module-boundary (Quiz-style, T4L1): make billing use the users public API, then commit"
