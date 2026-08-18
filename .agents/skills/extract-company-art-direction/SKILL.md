---
name: extract-company-art-direction
description: Research a target company from current, traceable visual evidence and synthesize a brand-safe, portfolio-specific art-direction package in the company's research directory. Use when the user asks to extract, define, refresh, or prepare a company's art direction for the portfolio. Do not use to create the CSS adapter, edit factual content, or approve final visual quality.
---

# Extract company art direction

Create an evidence-backed research handoff. Do not imitate the company and do not implement the theme.

## Required reading

Read, in order:

1. `AGENTS.md`
2. `.agents/memory/portfolio-system-strategy.md`
3. `portfolio-system/ART_DIRECTION_CONTRACT.md`
4. `portfolio-system/THEME_CONTRACT.md`
5. `portfolio-system/art-direction.schema.json`
6. `portfolio-system/art-direction-acceptance.schema.json`
7. `references/research-protocol.md`

For approval, also use `$review-company-art-direction` and its rubric. Never approve your own synthesis.

## Inputs

Resolve the company name, kebab-case slug, canonical official URL, region, and target role. A missing role
defaults to `company-wide` and is recorded; it is not by itself a reason to stop. Ask one focused question
only when similarly named entities, parent and product brands, or conflicting regional brands would produce
materially different directions.

Because company sites, campaigns, product surfaces, and licenses change, browse current sources during a
real extraction. Prefer official first-party pages. Search snippets may locate a source but cannot support a
claim. Follow access restrictions and never request login credentials.

## Workflow

1. Inspect `designs/<slug>/research/`. Preserve legacy or hand-authored files. If the canonical extraction
   directory already exists, compare before replacing it and preserve user edits. Before any writer runs,
   capture `scripts/get-protected-state.ps1 -RepoRoot <repo>` in coordinator state.
2. Establish a source-role matrix before extracting traits: corporate/brand, product/service, careers,
   design, newsroom, app store, regional, and campaign. Record conflicts instead of averaging them.
3. Use read-only research agents in parallel when available:
   - `company_brand_researcher` for identity, voice, source provenance, and cross-surface patterns;
   - `company_visual_researcher` for rendered composition, type, color, form, imagery, and license evidence.
4. The `company_art_direction_synthesizer` is the only writer. It creates exactly:
   - `sources.md`, the evidence ledger and source-role matrix;
   - `art-direction.json`, the machine-readable handoff matching the schema;
   - `art-direction.md`, the human-readable thesis, principles, decisions, Do/Don't, and limitations.
5. Keep observations, inferences, and portfolio decisions separate. Every material decision must cite existing
   evidence IDs. Use three to five principles, each expressed as observed fact -> abstract principle ->
   portfolio-specific decision.
6. Map candidates for every required variable in `THEME_CONTRACT.md`, but create no CSS. Record values as
   candidates with rationale, confidence, and evidence IDs.
7. Document observed fonts separately from safe alternatives. Never select a proprietary or unknown-license
   font. A safe alternative requires a license URL, verified Korean support, permitted PDF embedding, and
   available static weights.
8. Use `review-ready` only after the evidence minimum is met; otherwise use `draft`, `provisional`, or
   `blocked`. Run `scripts/validate-art-direction.ps1 -RepoRoot <repo> -CompanySlug <slug>`.
9. Capture protected state again and stop if it differs from the baseline. Invoke
   `$review-company-art-direction`. Two independent read-only reviews must examine the same SHA-256
   snapshot. The coordinator stores their returned reports verbatim under `reviews/`, then writes
   `acceptance.json` only when both pass, including the equal protected-state hashes. Reviewers remain read-only.
10. Run the validator again with `-RequireAcceptance`. If validation or review fails, send only cited defects
    back to the synthesizer, update the artifact, invalidate the old acceptance, and re-review the new hash.

## Honest stopping behavior

- Fewer than three relevant official contexts or two rendered/official-screenshot contexts: keep the artifact
  `provisional` or `blocked`; do not create acceptance.
- Login-only product surface: use public official screenshots or permission-cleared, de-identified user input;
  otherwise limit claims to public marketing evidence.
- No rendered evidence: record code-derived candidates as hypotheses and cap readiness below acceptance.
- Font or asset rights unresolved: put the original in `offLimits`, choose a verified safe alternative if one
  exists, or block apply readiness.
- Seasonal, regional, corporate, and product styles conflict: document the weighting and excluded direction.

## Protected paths

During extraction, do not modify `content/`, `result/`, `portfolio-system/`, or existing files
outside `designs/<slug>/research/art-direction/`. Research screenshots and raw page files are evidence only,
must not become portfolio assets, and should stay in ignored `designs/<slug>/research/raw/` if temporarily
needed.

The durable acceptance fingerprint covers source inputs only (`content/`, `result/content/`, the non-generated
portfolio system). The extraction writer still treats all of `result/` as read-only; excluding
`result/design/` from the durable hash only prevents later generated builds from making the research stale.

## Completion report

Report the canonical target, official sources used, output paths, status, unresolved limitations, validator
result, both reviewer scores, lower final score, and whether the package is accepted for a future application
workflow. Say explicitly that extraction acceptance does not approve final rendered design quality.
