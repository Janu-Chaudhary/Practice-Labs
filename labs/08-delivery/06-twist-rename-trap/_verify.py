# Hidden grader for lab 06 (the student never runs this). Run inside work/.
#   python3 _verify.py <check>
# Grades the COMMITTED migrations (git show main:...), applying them to an in-memory SQLite db.
import re
import sqlite3
import subprocess
import sys


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout


def at_main(path):
    return git("show", f"main:{path}")


files = sorted(f.split("/", 1)[1] for f in git("ls-tree", "--name-only", "main", "migrations/").split())
what = sys.argv[1]
ok = False

if what == "files":
    ok = files == ["V1__create_orders.sql", "V2__add_group_id.sql", "V3__add_order_items.sql"]

elif what == "v2-restored":
    prod = [l.split(" ", 1)[0] for l in git("log", "--format=%H %s", "main").splitlines()
            if l.split(" ", 1)[1] == "Add group_id column"]
    ok = len(prod) == 1 and at_main("migrations/V2__add_group_id.sql") == \
        git("show", f"{prod[0]}:migrations/V2__add_group_id.sql")

elif what == "no-rename-drop":
    ok = all(not re.search(r"\b(rename|drop)\b", at_main(f"migrations/{f}"), re.I) for f in files)

elif what in ("expand", "old-code"):
    def ver(f):
        m = re.match(r"V(\d+)__", f)
        return int(m.group(1)) if m else 999
    db = sqlite3.connect(":memory:")
    try:
        for f in sorted(files, key=ver):
            db.executescript(at_main(f"migrations/{f}"))
            if f.startswith("V2__"):   # production data that exists before V3 runs (old code writes it)
                db.executemany("INSERT INTO orders (customer, items, total) VALUES (?, ?, ?)",
                               [("ravi", "paneer thali, lassi", 240), ("meena", "veg biryani", 160),
                                ("asha", "paneer thali, paneer thali, paneer thali", 540)])
        cols = [r[1] for r in db.execute("PRAGMA table_info(orders)")]
        if what == "expand":
            rows = db.execute("SELECT items, order_items FROM orders ORDER BY id").fetchall()
            ok = {"items", "order_items", "group_id"} <= set(cols) and len(rows) == 3 \
                and all(a == b for a, b in rows)
        else:
            # old code (2.3) still works AND new code that writes both columns works
            db.execute("INSERT INTO orders (customer, items, total) VALUES ('kabir', 'lassi', 60)")
            db.execute("INSERT INTO orders (customer, items, order_items, total) "
                       "VALUES ('zoya', 'lassi', 'lassi', 60)")
            ok = db.execute("SELECT COUNT(*) FROM orders").fetchone()[0] == 5
    except Exception as e:  # SQL error in a migration, missing column, NOT NULL violation...
        print(e)
        ok = False

sys.exit(0 if ok else 1)
