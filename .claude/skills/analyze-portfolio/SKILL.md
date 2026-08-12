---
name: analyze-portfolio
description: >
  Analyze a REFERENCE/example portfolio PDF (default portfolio-example/portfolio.pdf) and
  write a structure + content analysis next to the source file (e.g.
  portfolio-example/portfolio-analysis.md). Use when the user asks to analyze a sample
  portfolio, or after a reference PDF is added/replaced under portfolio-example/. This is
  for reference material that is NOT the user's own portfolio — it never writes to
  content/, which is reserved for the user's own real content.
---

# /analyze-portfolio

Entry point for analyzing a reference portfolio document (something the user is using as
inspiration/example — e.g. `portfolio-example/portfolio.pdf` — not their own content) and
producing a structural/content analysis kept alongside the source file.

## What to do

1. Resolve the target PDF: the argument passed to this skill if given, otherwise
   `portfolio-example/portfolio.pdf`. Fail clearly if it doesn't exist.
2. Delegate the extraction and write-up to the **portfolio-analyzer** subagent
   (`.claude/agents/portfolio-analyzer.md`) via the Agent tool, passing it the resolved
   PDF path. Run it in the foreground (`run_in_background: false`) — the next step
   (reporting to the user) depends on its result and there's nothing else useful to do
   meanwhile.
3. Relay the agent's summary to the user: where the analysis file was written, any
   `<!-- verify -->` markers left for manual double-checking against the PDF, and
   anything skipped because an existing analysis looked hand-edited.

## Scope — read this before running

- Output always lands **next to the source PDF** (same directory), never in `content/`.
  `content/` is reserved for the user's own real portfolio content, which this skill does
  not produce and should never overwrite.
- If it's unclear whether a given PDF is the user's own content or a reference example,
  ask before running — don't assume.

## Why a separate skill instead of doing it inline

The extraction has a real, non-obvious gotcha (this environment's `pdftotext` silently
mangles Korean/CJK text unless `-enc UTF-8` is passed explicitly — see the agent
definition for details). Routing through the dedicated agent keeps that procedural
knowledge in one place instead of being rediscovered each time.
