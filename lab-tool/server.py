#!/usr/bin/env python3
"""Local quiz-style lab tool: task + file panel + real terminal + check button.

Run:  python3 server.py   then open http://127.0.0.1:8765
Only listens on 127.0.0.1. Uses only the Python standard library.
"""
import codecs, fcntl, json, os, pty, re, select, signal, struct, subprocess, termios, threading, time
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from urllib.parse import urlparse, parse_qs

HERE = Path(__file__).resolve().parent
LABS = HERE.parent / "labs"
PORT = int(os.environ.get("LAB_TOOL_PORT", "8765"))
HIDDEN = {".git", "remote.git", "node_modules", "__pycache__", ".pytest_cache"}
MAX_FILE = 512 * 1024


def list_labs():
    topics = []
    for tdir in sorted(p for p in LABS.iterdir() if p.is_dir() and re.match(r"\d\d-", p.name)):
        labs = []
        for ldir in sorted(p for p in tdir.iterdir() if p.is_dir() and (p / "TASK.md").exists()):
            first = (ldir / "TASK.md").read_text(encoding="utf-8", errors="replace").splitlines()
            title = next((l.lstrip("# ").strip() for l in first if l.startswith("#")), ldir.name)
            lvl = "twist" if "twist" in ldir.name else "quiz" if "quiz" in ldir.name else "drill"
            labs.append({"id": f"{tdir.name}/{ldir.name}", "name": ldir.name, "title": title, "level": lvl})
        topics.append({"id": tdir.name, "name": tdir.name[3:].replace("-", " ").title(), "labs": labs})
    return topics


def lab_dir(lab_id):
    p = (LABS / lab_id).resolve()
    if LABS.resolve() not in p.parents or not (p / "TASK.md").exists():
        raise ValueError("unknown lab")
    return p


class Terminal:
    """One bash process on a pseudo-terminal; output kept in a growing buffer the browser polls."""

    def __init__(self):
        self.lock = threading.Lock()
        self.pid = None
        self.fd = None
        self.buf = ""
        self.base = 0  # absolute offset of buf[0]
        self.gen = 0   # bumps every restart so the browser can clear its screen
        self.size = (30, 100)  # rows, cols: last size the browser reported, given to every new shell

    def start(self, cwd):
        self.stop()
        env = dict(os.environ, TERM="xterm-256color", PATH=f"{LABS / 'bin'}:{os.environ.get('PATH', '')}",
                   PS1=r"\[\e[32m\]\W\[\e[0m\] $ ", GIT_PAGER="cat")
        pid, fd = pty.fork()
        if pid == 0:
            os.chdir(cwd)
            os.execvpe("bash", ["bash", "--norc", "-i"], env)
        # a fresh pty is 0x0; without the real width bash wraps long lines in the wrong place
        fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", *self.size, 0, 0))
        with self.lock:
            self.pid, self.fd, self.buf, self.base = pid, fd, "", 0
            self.gen += 1
            gen = self.gen
        threading.Thread(target=self._reader, args=(fd, gen), daemon=True).start()

    def _reader(self, fd, gen):
        dec = codecs.getincrementaldecoder("utf-8")("replace")
        while True:
            try:
                r, _, _ = select.select([fd], [], [], 1)
                if not r:
                    if self.gen != gen:
                        return
                    continue
                data = os.read(fd, 65536)
            except OSError:
                return
            if not data:
                return
            text = dec.decode(data)
            with self.lock:
                if self.gen != gen:
                    return
                self.buf += text
                if len(self.buf) > 400_000:  # keep memory bounded
                    cut = len(self.buf) - 200_000
                    self.buf = self.buf[cut:]
                    self.base += cut

    def stop(self):
        with self.lock:
            pid, fd = self.pid, self.fd
            self.pid = self.fd = None
        if pid:
            try:
                os.kill(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
            except (ProcessLookupError, ChildProcessError):
                pass
        if fd is not None:
            try:
                os.close(fd)
            except OSError:
                pass

    def write(self, data):
        if self.fd is not None:
            os.write(self.fd, data.encode())

    def resize(self, cols, rows):
        self.size = (rows, cols)
        if self.fd is not None:
            fcntl.ioctl(self.fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))

    def read(self, since, gen):
        with self.lock:
            if gen != self.gen:
                return {"gen": self.gen, "pos": self.base + len(self.buf), "data": self.buf, "reset": True}
            start = max(since - self.base, 0)
            return {"gen": self.gen, "pos": self.base + len(self.buf), "data": self.buf[start:], "reset": False}


TERM = Terminal()
STATE = {"lab": None}


def run_script(path, cwd):
    p = subprocess.run(["bash", str(path)], cwd=cwd, capture_output=True, text=True, timeout=300,
                       env=dict(os.environ, PATH=f"{LABS / 'bin'}:{os.environ.get('PATH', '')}"))
    return {"code": p.returncode, "output": p.stdout + p.stderr}


def file_tree(root):
    out = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in HIDDEN)
        rel = Path(dirpath).relative_to(root)
        for d in dirnames:
            out.append({"path": str(rel / d) if str(rel) != "." else d, "dir": True})
        for f in sorted(filenames):
            p = rel / f if str(rel) != "." else Path(f)
            st = (Path(dirpath) / f).stat()
            out.append({"path": str(p), "dir": False, "mtime": st.st_mtime, "size": st.st_size})
    return sorted(out, key=lambda e: e["path"])


def safe_path(rel):
    work = (lab_dir(STATE["lab"]) / "work").resolve()
    p = (work / rel).resolve()
    if p != work and work not in p.parents:
        raise ValueError("path outside work/")
    return p


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def send(self, obj, code=200, ctype="application/json"):
        body = obj if isinstance(obj, bytes) else json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def body(self):
        n = int(self.headers.get("Content-Length") or 0)
        return json.loads(self.rfile.read(n) or b"{}")

    def do_GET(self):
        u = urlparse(self.path)
        q = {k: v[0] for k, v in parse_qs(u.query).items()}
        try:
            if u.path == "/":
                return self.send((HERE / "index.html").read_bytes(), ctype="text/html; charset=utf-8")
            if u.path == "/api/labs":
                return self.send({"topics": list_labs(), "current": STATE["lab"]})
            if u.path == "/api/term":
                return self.send(TERM.read(int(q.get("since", 0)), int(q.get("gen", -1))))
            if u.path == "/api/doc":  # TASK.md or SOLUTION.md of the current lab
                name = {"task": "TASK.md", "solution": "SOLUTION.md"}[q["which"]]
                return self.send({"text": (lab_dir(STATE["lab"]) / name).read_text(encoding="utf-8", errors="replace")})
            if u.path == "/api/files":
                work = lab_dir(STATE["lab"]) / "work"
                return self.send({"ready": work.is_dir(), "files": file_tree(work) if work.is_dir() else []})
            if u.path == "/api/file":
                p = safe_path(q["path"])
                if p.stat().st_size > MAX_FILE:
                    return self.send({"error": "file too large to show"}, 400)
                raw = p.read_bytes()
                if b"\0" in raw[:4096]:
                    return self.send({"error": "binary file (open it from the terminal instead)"}, 400)
                return self.send({"text": raw.decode("utf-8", "replace"), "mtime": p.stat().st_mtime})
            self.send({"error": "not found"}, 404)
        except Exception as e:  # noqa: BLE001 - report every failure to the page
            self.send({"error": str(e)}, 400)

    def do_POST(self):
        u = urlparse(self.path)
        try:
            b = self.body()
            if u.path == "/api/open":  # choose a lab; start a terminal in it (work/ if it exists)
                d = lab_dir(b["lab"])
                STATE["lab"] = b["lab"]
                TERM.start(d / "work" if (d / "work").is_dir() else d)
                return self.send({"ok": True, "ready": (d / "work").is_dir()})
            if u.path == "/api/setup":
                d = lab_dir(STATE["lab"])
                TERM.stop()  # setup deletes work/, never leave the shell inside it
                res = run_script(d / "setup.sh", d)
                TERM.start(d / "work" if (d / "work").is_dir() else d)
                return self.send(res)
            if u.path == "/api/check":
                d = lab_dir(STATE["lab"])
                return self.send(run_script(d / "check.sh", d))
            if u.path == "/api/term/input":
                TERM.write(b["data"])
                return self.send({"ok": True})
            if u.path == "/api/term/resize":
                TERM.resize(int(b["cols"]), int(b["rows"]))
                return self.send({"ok": True})
            if u.path == "/api/file":
                p = safe_path(b["path"])
                if b.get("create"):  # "+ New file": make parent folders, never overwrite
                    if p.exists():
                        return self.send({"error": f"{b['path']} already exists"}, 400)
                    p.parent.mkdir(parents=True, exist_ok=True)
                p.write_text(b["text"], encoding="utf-8")
                return self.send({"ok": True, "mtime": p.stat().st_mtime})
            self.send({"error": "not found"}, 404)
        except Exception as e:  # noqa: BLE001
            self.send({"error": str(e)}, 400)


if __name__ == "__main__":
    srv = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    srv.daemon_threads = True
    print(f"Lab tool running: http://127.0.0.1:{PORT}   (Ctrl+C to stop)")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        TERM.stop()
