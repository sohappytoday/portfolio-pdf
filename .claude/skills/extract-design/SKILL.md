---
name: extract-design
description: >
  Extract a target company's visual design language (colors, typography, shape,
  elevation, tone, layout patterns) from their public website, and write it up as a
  design brief under designs/<company-slug>/research/design-brief.md. Use when the user
  names a company they're applying to and wants a style reference for a company-themed
  portfolio design. Produces reference material only — never touches content/ or
  portfolio-example/, and never includes the company's logo/brand assets.
---

# /extract-design

Entry point for pulling a target company's design language off their live site, ahead of
building a company-styled version of the portfolio (a separate, later step that reads
both this brief and `content/`).

## What to do

1. Resolve the company → slug + URL. Ask if either is ambiguous.
2. Delegate to the **design-extractor** subagent (`.claude/agents/design-extractor.md`)
   via the Agent tool, passing the company name, slug, and URL. Run in the foreground
   (`run_in_background: false`) — the next step depends on its result.
3. Relay the agent's summary: where the brief was written, headline findings
   (color/type/shape), and anything flagged low-confidence or unresolved.

## Tooling this skill relies on

- `.claude/skills/extract-design/scripts/extract-css-tokens.sh <url> <output-dir>` — fetches
  a page and every linked stylesheet, aggregates candidate color/font/radius/shadow tokens
  by frequency. Signal, not ground truth — see the script's own header comment and the
  design-extractor agent for how to read its output critically.
- `WebFetch` — for qualitative reading (tone, structure, copy) that CSS extraction can't
  see.

No headless-browser/screenshot capability exists in this environment, so nothing here
produces a true visual render. If the user provides a screenshot, that can be used to
correct/refine an existing brief — mention this as an option if precision matters more
than the first pass suggests.

## Scope

- Output always lands under `designs/<slug>/research/`, never in `content/` or
  `portfolio-example/`.
- This is stylistic reference, not a brand clone: the brief must exclude the company's
  logo, mascot, proprietary illustration style, and slogans — inspiration, not
  impersonation.
