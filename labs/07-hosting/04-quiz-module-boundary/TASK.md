# 04 - Billing reads the users table (Quiz-style, T4L1)

**Context:** `work/` is a Git repo (branch `main`, 1 commit) holding a small **modular monolith**:
one deployable, one process, split into modules that may only talk through **public APIs**.

```
shop/users/api.py       PUBLIC API of users: get_email(user_id), get_display_name(user_id)
shop/users/_store.py    PRIVATE: USERS_TABLE, the raw users "table"
shop/billing/invoice.py billing: build_invoice(user_id, amount_cents)
tests/test_invoice.py   behaviour tests
tests/test_boundaries.py  boundary check (like Packwerk in CI): billing may use users ONLY via shop.users.api
```

A billing developer took a shortcut: `invoice.py` imports `USERS_TABLE` from `shop.users._store`
and reads the rows directly ("it's one process, so it's faster"). CI now fails twice:
the boundary check reports a dependency violation, and invoices go out to `"  Ana.Silva@Example.COM "`
because the rule "emails are trimmed and lower-cased" lives in the users module's API, which billing skipped.

**Task:**

1. Run `pytest` and read both failures.
2. Change `shop/billing/invoice.py` so it gets the email and the name **only through the users
   public API** (`shop.users.api`). The returned dict keeps the same keys.
3. Run `pytest` again: all tests must pass.
4. Commit the fix on `main` with the message `billing: use users public API`.

**Stop rules:** change only `shop/billing/invoice.py`. Don't edit, skip or delete tests, don't touch
the `users` module or `pytest.ini` (silencing the check is not a fix). Exactly one new commit.

**Hints**
- Edit `invoice.py` in the Files panel, Ctrl+S. The terminal is for `pytest` and `git`.
- `pytest -q` = short output; `pytest tests/test_boundaries.py` runs one file.
- Look at `shop/users/api.py`: which two functions give billing what it needs?
- `git status` before committing: only `invoice.py` should be modified. `git add` that one file.

**What will be checked**
- `pytest` passes, including `tests/test_boundaries.py`
- `invoice.py` has no `_store` / `USERS_TABLE` and imports `shop.users.api`
- `tests/`, `shop/users/`, `pytest.ini` unchanged
- `main` has exactly 2 commits; the last one is `billing: use users public API` and changes only
  `shop/billing/invoice.py`; working tree clean
