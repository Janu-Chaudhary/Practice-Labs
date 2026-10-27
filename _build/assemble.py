#!/usr/bin/env python3
"""Assemble guide.html from template.html + sections/*.html (sorted by filename)."""
from pathlib import Path

build = Path(__file__).resolve().parent
sections = sorted((build / "sections").glob("*.html"))
body = "\n".join(p.read_text(encoding="utf-8") for p in sections)
html = (build / "template.html").read_text(encoding="utf-8").replace("<!--SECTIONS-->", body)
out = build.parent / "guide.html"
out.write_text(html, encoding="utf-8")
print(f"wrote {out} from {len(sections)} sections: {', '.join(p.name for p in sections)}")
