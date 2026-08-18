---
name: build-portfolio
description: >
  Build the actual per-page PDF portfolio (portfolio-1.pdf, portfolio-2.pdf, …) for one
  company, styled per its design brief and populated only with real content. Renders via
  headless Chrome/Edge (no node/npm needed) and does a visual QA pass across pages before
  finishing. Use when the user wants the real portfolio built/rendered for a company whose
  design brief already exists (from /extract-design) and whose page-ready content already
  exists (result/content/NN-slug.md, from /curate-content).
---

# /build-portfolio

Entry point for turning a company's design brief + the already-planned page content into
the actual rendered PDF portfolio, one page at a time.

## What to do

1. Confirm prerequisites exist: `designs/<slug>/research/design-brief.md` and
   `result/content/NN-slug.md` files (the page plan + content, produced by
   `/curate-content`). If either is missing, say so and point at `/extract-design` or
   `/curate-content` first rather than guessing or inventing a page plan yourself.
2. Delegate to the **portfolio-builder** subagent (`.claude/agents/portfolio-builder.md`)
   via the Agent tool, passing the company slug. Run in the foreground
   (`run_in_background: false`) unless the user explicitly wants it backgrounded — this
   involves many sequential render+inspect steps and the user will likely want to see
   the result as soon as it's ready.
3. Relay the agent's report: final PDF file list, any font/brand substitutions made,
   anything fixed during visual QA, and any page-planning problems it flagged back
   instead of resolving itself (that would mean returning to `/curate-content`).

## Tooling this skill relies on

- `.claude/skills/build-portfolio/scripts/render-page.sh <html> <out-basename>
  [window-size]` — headless-renders one HTML page to a PDF + PNG using whichever of
  Chrome/Edge is installed (checked at standard Program Files locations, not required on
  PATH). No node/npm/playwright involved.

## Scope

- Output goes under `result/design/<company-slug>/` only — HTML/CSS sources and PNG
  previews in `pages/`, final numbered PDFs (`portfolio-N.pdf`) at that directory's top
  level.
- Never fabricates content (only real facts from `result/content/`, the sole
  authoritative source — no fallback to `content/`) and never includes the target
  company's brand assets (logo, proprietary font, etc.) — both enforced by
  `portfolio-builder`'s guardrails.
- For a first run on a new company, consider building just the first page and reviewing
  it before generating the rest, if the user wants a checkpoint before committing to the
  full set.
