---
name: curate-content
description: >
  Split content/ (organized by topic) into result/content/NN-slug.md (one file per
  portfolio page, in page order), tight and signal-forward, then score it with the
  DevOps-rubric reviewer to check it actually reads better — never by inventing facts,
  only by cutting filler and resurfacing buried real signal. Use when the user says
  content is too verbose/unfocused, or asks to trim/curate/tighten/replan the portfolio
  content, or wants result/content/ generated or refreshed from content/.
---

# /curate-content

Entry point for turning `content/` (topic-organized, often verbose) into the page-ready
`result/content/NN-slug.md` files, then validating the result — closing the "작성 → 검수
→ 반복" loop the same way this project's own build process already works.

## What to do

1. Delegate to the **content-curator** subagent (`.claude/agents/content-curator.md`) via
   the Agent tool to produce/update `result/content/`. Run in the foreground
   (`run_in_background: false`) — later steps depend on its result. Its one hard rule:
   never invent facts — only reorganize/trim/resurface what's already in `content/`.
2. Delegate to the **portfolio-reviewer** subagent (`.claude/agents/portfolio-reviewer.md`)
   to score the result. This is the *explicit override* case documented in that agent's
   definition: the target is `result/content/`, not the default `content/` — tell it so
   directly, and it will write the review next to the source (`result/content/review.md`)
   instead of just replying inline.
3. **At most one more curation round** if the review surfaces fixable issues that are
   genuinely about structure/emphasis (buried facts, unclear framing) — not issues that
   would require inventing new facts. Re-run content-curator with the review's specific
   findings as input, then re-review. Stop after this second pass regardless of score —
   don't loop indefinitely, and don't let "improve the score" justify a third pass that
   starts pressuring toward fabrication.
4. Relay to the user: what changed per file, the before/after review score if a second
   pass happened, and — most importantly — any rubric gaps the reviewer flagged that
   genuinely have no supporting evidence in `content/`. Those need the user to add real
   content, not more editing.

## Why this is two agents, not one

Curating and scoring are different jobs with different failure modes: a single agent
asked to both "trim this" and "make it score well" tends to drift toward filling rubric
gaps with plausible-sounding filler. Keeping the reviewer separate and read-only, and
telling the curator explicitly that fabrication is never acceptable, keeps the incentive
structure honest — the score is a check on the work, not the work's goal.

## Scope

- Writes only to `result/content/`. Never modifies `content/` itself.
- `result/content/` is shared across all companies (not per-company) — this skill doesn't
  take a company/tone parameter and shouldn't be used to produce company-specific
  wording; that's a `result/design/<slug>/` concern if it's ever needed at all.
