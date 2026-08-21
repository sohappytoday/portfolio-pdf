#!/usr/bin/env python3
"""Assemble every company-neutral page layout into one printable document.

Each result/layout/<page>/<page>.html holds a single <main class="page"> that is already fixed at
1280x720 with position:relative, so the pages can simply be concatenated: one .page per printed
sheet. The shared @page rule in portfolio-system/core.css supplies the 1280x720 sheet size, and the
break rule added here starts a new sheet after every page except the last.

Usage (from the repository root):
    python result/layout/total/build-total.py
Then print total.html to PDF with headless Chrome; build-total.ps1 does both steps.
"""

import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
LAYOUT_ROOT = os.path.dirname(HERE)

PAGE_DIR = re.compile(r"^\d{2}-")
MAIN_BLOCK = re.compile(r"(<main\b.*?</main>)", re.S)


def collect_pages():
    names = sorted(n for n in os.listdir(LAYOUT_ROOT) if PAGE_DIR.match(n))
    pages = []
    for name in names:
        path = os.path.join(LAYOUT_ROOT, name, name + ".html")
        if not os.path.isfile(path):
            sys.stderr.write("missing layout: %s\n" % path)
            sys.exit(1)
        html = io.open(path, encoding="utf-8").read()
        match = MAIN_BLOCK.search(html)
        if not match:
            sys.stderr.write("no <main> found in: %s\n" % path)
            sys.exit(1)
        pages.append((name, match.group(1)))
    return pages


def main():
    pages = collect_pages()

    head = """<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=1280, initial-scale=1">
  <title>김지오 — 포트폴리오</title>
  <link rel="stylesheet" href="theme.css">
  <style>
    /* One .page per printed sheet. The last page must not emit a trailing blank sheet. */
    .page { break-after: page; page-break-after: always; }
    .page:last-of-type { break-after: auto; page-break-after: auto; }
    /* On screen the pages read as a stack; print ignores this margin. */
    @media screen { body { background: #55554e; } .page + .page { margin-top: 24px; } }
  </style>
</head>
<body>
"""
    body = "\n".join("  <!-- %s -->\n  %s" % (name, block) for name, block in pages)
    out = head + body + "\n</body>\n</html>\n"

    target = os.path.join(HERE, "total.html")
    io.open(target, "w", encoding="utf-8", newline="\n").write(out)
    sys.stdout.write("pages=%d -> total.html\n" % len(pages))
    for name, _ in pages:
        sys.stdout.write("  " + name + "\n")


if __name__ == "__main__":
    main()
