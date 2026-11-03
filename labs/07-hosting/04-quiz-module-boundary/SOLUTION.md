# Solution - 04-quiz-module-boundary

## 1. See the failures
```bash
cd work
pytest -q
# FF.   2 failed, 1 passed
# test_billing_uses_only_the_users_public_api:
#   Dependency violation: billing -> users (not in users' public API shop.users.api):
#     shop/billing/invoice.py:1 imports shop.users._store
#     shop/billing/invoice.py:5 uses USERS_TABLE
# test_invoice_for_ana:
#   'to': '  Ana.Silva@Example.COM '  !=  'ana.silva@example.com'
```
The second failure is *why* boundaries matter: the users module owns the email rule; billing
read the raw table and skipped the rule.

## 2. Fix invoice.py
In the Files panel open `shop/billing/invoice.py`, make it read exactly this, Ctrl+S:
```python
from shop.users import api as users


def build_invoice(user_id: int, amount_cents: int) -> dict:
    return {
        "to": users.get_email(user_id),
        "name": users.get_display_name(user_id),
        "amount": f"{amount_cents / 100:.2f} EUR",
    }
```
(`from shop.users.api import get_email, get_display_name` and calling them directly is just as good.)
Why: billing now depends only on the users **contract** (function names + meaning). users can change
how it stores data (dict today, a Postgres table tomorrow, maybe a separate service later) without
breaking billing. That enforced boundary is the **seam**.

## 3. Test
```bash
pytest -q          # 3 passed
```

## 4. Commit
```bash
git status                         # modified: shop/billing/invoice.py  (only this)
git add shop/billing/invoice.py
git commit -m "billing: use users public API"
git log --oneline                  # 2 commits
git status                         # nothing to commit, working tree clean
```

## Common wrong attempts
- `from shop.users._store import USERS_TABLE` kept "just for the name" -> still a violation.
  Every use of the private table counts, also `import shop.users._store` or `_store.USERS_TABLE`.
- Copying the rule into billing (`user["email"].strip().lower()`) -> the invoice test passes, the
  boundary test still fails, and now the rule lives in two places that will drift apart.
- Adding `api.USERS_TABLE` or importing `_store` through `api` -> the check also catches the names
  `_store` / `USERS_TABLE` used anywhere in billing.
- Deleting or `@pytest.mark.skip`-ing the boundary test, or editing `pytest.ini` -> checked; that's
  "silencing the check", which the T4L1 lecture (and Quiz 2A Q13) calls wrong. A comment or a team
  agreement is not enforcement either: only an automated check (Packwerk in CI) is.
- "Move users to its own microservice so billing can't reach in" -> distribution needs measured pain
  (Fowler: >50 engineers or very different scaling needs). A modular monolith + a CI check is enough.
- `git commit -am "..."` is fine here (only tracked files changed). `git add .` is fine too, because
  `.gitignore` hides `__pycache__/`.
- Two commits (e.g. "wip" then "fix") -> exactly one new commit is checked. Undo with
  `git reset --soft HEAD~2` and commit once.
