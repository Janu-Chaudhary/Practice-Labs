# Hidden extra checks for lab 05 (the student never runs this).
#   python3 _grade.py <path to rollout.py> <check name>
import hashlib
import importlib.util
import sys

path, what = sys.argv[1], sys.argv[2]
src = open(path, encoding="utf-8").read()
spec = importlib.util.spec_from_file_location("rollout_under_test", path)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


def ref(flag, user):
    return int.from_bytes(hashlib.sha256(f"{flag}:{user}".encode()).digest()[:4], "big") % 100


users = [f"user_{i}" for i in range(1, 3001)] + ["asha", "ravi", "meena", "kabir", "zoya"]
if what == "no-random":
    ok = "random" not in src
elif what == "bucket-spec":
    ok = all(mod.bucket(f, u) == ref(f, u) for f in ["group_order", "new_menu", "x"] for u in users[:800])
elif what == "enabled-spec":
    ok = all(mod.is_enabled(f, u, p) == (ref(f, u) < p)
             for f in ["group_order", "new_menu"] for u in users[:1500] for p in (0, 1, 10, 37, 50, 99, 100))
else:
    ok = False
sys.exit(0 if ok else 1)
