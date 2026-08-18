# Portfolio system strategy — durable project memory

- Recorded: 2026-08-18
- Status: accepted direction; implementation evolves through the workflows below
- Scope: portfolio design first; content improvement follows later

## Goal

Build one high-quality portfolio system that keeps content and production behavior stable while a
target company's character can be applied as art direction. The result should feel intentionally
art-directed for each application, not like a generic template with a changed accent color.

## Core decision

Use a `70/30` architecture:

- Stable core (~70%): canvas, grid, margins, typography roles, spacing, page types, reusable visual
  storytelling components, accessibility, rendering, PDF preflight, and QA evidence.
- Company layer (~30%): palette, display-type personality, shape, surface/elevation, imagery,
  icon/line treatment, motion-like rhythm, and tone. It may change expression but not facts or page structure.

The percentage is a design boundary, not a measured file-size ratio.

## What “premium” means

Premium quality is judged through explicit evidence, not the word itself:

1. Typography: licensed Korean-capable fonts, real scale, controlled line length and optical detail.
2. Layout: stable grid, intentional whitespace, density contrast, and precise alignment.
3. Hierarchy: one primary focal point per page and a clear scan path within three seconds.
4. Visual storytelling: metrics, comparisons, architecture, and process are visualized instead of boxed prose.
5. Brand fit: the company layer changes character while preserving the core and avoiding imitation.
6. Production: no overflow, broken glyphs, missing pages, non-selectable text, or unlicensed assets.

## Workflow architecture

1. `build-common-portfolio-system`: create or revise the stable visual core and contracts.
2. `extract-company-art-direction`: research current official company surfaces and produce a traceable,
   brand-safe handoff under `designs/<slug>/research/art-direction/`. It maps theme candidates but creates no CSS.
3. `apply-company-art-direction`: consume only a hash-matching accepted extraction, create a licensed adapter,
   and render immutable evidence without mutating source facts or semantic DOM. It supports `adapter-proof`
   now and `portfolio-render` only when the common system supplies complete `result/layout/` neutral HTML.
4. `review-applied-portfolio`: independently review the exact input lock, preflight, and output-set hash with
   contract and visual reviewers; adjudicate material score divergence.
5. `review-portfolio-system`: review changes to the reusable core and the workflow framework itself.

## Agent roles

- Architect: the only writer for the common system during a build pass.
- Brand and visual researchers: parallel read-only inputs for company extraction.
- Company art-direction synthesizer: the only writer for one extraction package and never its reviewer.
- Evidence and fit verifiers: independent, read-only reviewers of the same extraction hash.
- System verifier and visual QA: independent, read-only reviewers with evidence-backed scores.
- Company theme applier: the only writer for application source. Applied-theme contract and visual verifiers
  review immutable builds; an adjudicator resolves material divergence.
- A reviewer never edits the artifact it scores. The architect fixes cited failures, then reviewers re-score.

## Hooks boundary

Hooks may check manifests, required files, schemas, hardcoded brand leakage, paths, page dimensions,
font declarations, overflow signals, text extraction, numbering, and build success. Hooks do not
judge taste, luxury, hierarchy, or storytelling; those require rendered-page review.

Application hooks perform fast source/schema/path checks only. Chrome rendering and PDF inspection remain
explicit workflow steps so ordinary edits do not trigger expensive or destructive production work.

## Application output decision

- Authored source lives at `designs/<slug>/application/`.
- Generated output is append-only at `result/design/<slug>/builds/<build-id>/`.
- `adapter-proof` approves only theme-contract handoff against sparse/dense fixtures.
- `portfolio-render` additionally requires one neutral layout per content page and all PDF tools.
- An accepted build may be referenced by `current.json`; legacy top-level output is preserved unless a separate
  migration is explicitly authorized.

## Acceptance contract

For this workflow framework: deterministic validation passes, hard blockers are zero, and two
independent workflow-readiness reviews each score at least 97/100. For a rendered portfolio: use
the design-quality rubric in `portfolio-system/QUALITY_GATE.md` with the same two-reviewer rule.
The lower score is final. A difference above two total points or one point in any category triggers adjudication.

## Non-negotiable constraints

- Never fabricate experience, metrics, ownership, or outcomes.
- Never place company-specific tokens in the common core.
- Never require content or page-structure edits merely to switch themes.
- Never treat self-review as independent verification.
- Never use proprietary brand assets or fonts without confirmed permission.
- Do not optimize for the score by hiding defects; every deduction needs file/page evidence.
