# Company art-direction extraction contract

Version: 1.0.0

## Purpose

This contract turns current, traceable company evidence into a portfolio-specific art-direction brief.
It is a research and decision artifact, not a company theme and not permission to copy a brand.

## Canonical output

Each target company uses one slug and one extraction directory:

```text
designs/<slug>/research/art-direction/
  sources.md
  art-direction.json
  art-direction.md
  reviews/*.json         schema-valid verbatim read-only reviewer reports, stored by the coordinator
  acceptance.json        written only after independent review passes
```

Raw notes already under `designs/<slug>/research/` remain inputs and are never silently overwritten.
The extraction workflow may create only the directory above. It treats `content/`, `result/`,
`portfolio-system/core.css`, and `portfolio-system/themes/` as read-only.

## Evidence minimum

An extraction eligible for acceptance must include:

- an unambiguous company, canonical official URL, research date, region, and target role or declared
  company-wide scope;
- at least three distinct official visual contexts, covering the company or brand, its product or
  service, and a third relevant surface such as careers, design, newsroom, an official app store, or
  an official brand guide;
- at least two contexts inspected as rendered pages or official screenshots;
- stable evidence IDs linking every material observation, inference, principle, and theme candidate
  to `sources.md` and `art-direction.json`;
- stable source IDs identifying distinct source surfaces; context coverage is counted by source ID, not by
  freely chosen labels;
- explicit confidence, access state, source role, observation method, and collection date;
- a font and restricted-asset register with license, Korean glyph, and PDF-embedding status.

Search snippets are discovery aids, not evidence. CSS frequency is a candidate signal and must be
cross-checked against rendered evidence before it supports a high-confidence visual claim.

## Reasoning chain

Every adopted direction follows this chain:

```text
observed fact -> abstract principle -> portfolio-specific decision -> evidence IDs
```

Observations describe what was directly visible or inspectable. Inferences explain what the observations
may mean. Decisions translate the principle into semantic portfolio tokens or page-type guidance.
These are separate fields; certainty in one does not silently transfer to the next.

## Brand and access safety

- Never request credentials, bypass authentication, evade access controls, or retain personal data.
- Never store or reuse a company logo, wordmark, mascot, slogan, proprietary illustration, production
  screenshot, production CSS, or unlicensed font as a portfolio asset.
- A proprietary or unknown-license typeface may be documented as observed but cannot be selected as a
  portfolio font. An alternative requires verified licensing, Korean glyph coverage, required static
  weights, and PDF embedding rights.
- Marketing and product UI conclusions stay separate when product surfaces are unavailable.
- Conflicting regional, seasonal, product, corporate, and recruiting surfaces are recorded rather than
  averaged. Source relevance to the target role determines the documented weighting.

## Status and stopping rules

`art-direction.json` uses one research status:

- `draft`: synthesis is incomplete.
- `review-ready`: deterministic evidence requirements pass and the unchanged snapshot may be sent to reviewers.
- `provisional`: useful evidence exists, but a declared limitation prevents acceptance.
- `blocked`: company identity, required visual evidence, or licensing cannot be resolved safely.

If the target entity is genuinely ambiguous, stop and ask one focused question. If a product is login-only,
use only official public screenshots or user-provided, permission-cleared and de-identified material. If two
rendered official contexts cannot be inspected, do not claim 97/100 readiness.

Only `acceptance.json` can declare `PASS`; `review-ready` alone is not acceptance. It binds two independent reviews to the SHA-256 hash of the exact
`art-direction.json`. The lower score is final. Both reviewers must score at least 97/100, all critical
category floors must pass, and hard blockers must be zero. A score is an operational rubric result, not a
statistical accuracy probability.

Each report follows `art-direction-review.schema.json`; acceptance follows
`art-direction-acceptance.schema.json`. Each reviewer records the same artifact hash,
its seven integer category scores, total, any score cap, hard blockers, and a path to its immutable report.
Reviewer roles must be distinct; category totals and floors are recalculated by the validator rather than
trusted from a boolean claim. The report hash is recorded and verified. If the primary reviewers differ by
more than two total points or more than one point in any category, a third adjudicator is required; the
conservative minimum of all recorded reviewer totals remains the machine gate.

Before the synthesis writer starts, the coordinator captures the combined protected-source hash with
`get-protected-state.ps1`; it captures it again after synthesis and review. Acceptance requires equal before
and after hashes and records the file count. The validator also compares the recorded after hash with the
current protected state, so a later core/content change invalidates the handoff until it is reviewed again.
The protected source set is `content/`, `result/content/`, `portfolio-system/` excluding `.generated/`, and
legacy `.claude/`. Generated `result/design/` output is intentionally excluded so applying an accepted art
direction cannot invalidate its own research acceptance.

## Handoff to theme application

The future application workflow may consume only a hash-matching `PASS` artifact. It maps `themeCandidates`
to `THEME_CONTRACT.md`, then proves the adapter with identical-DOM fixtures and rendered PDF QA. Extraction
does not create CSS and acceptance here does not approve a final rendered portfolio.
