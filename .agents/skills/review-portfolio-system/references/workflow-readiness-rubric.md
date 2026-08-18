# Workflow readiness rubric — 100 points

This scores the automation framework created in this repository, not the visual quality of a future PDF.

| Category | Points | Full-credit evidence |
|---|---:|---|
| Architecture and boundaries | 20 | Durable memory, source-of-truth paths, stable-core/company-layer split, and explicit non-goals agree across files. |
| Skill actionability | 20 | Build and review skills have precise triggers, required inputs, ordered steps, failure behavior, outputs, and guardrails. |
| Agent independence | 15 | One writer, two read-only review roles, identical snapshot/rubric, lower-score rule, and adjudication are explicit. |
| Deterministic validation and hooks | 15 | Validator is executable and useful; hook is correctly scoped, platform-aware, quick, and does not perform aesthetic judgment. |
| Design contract completeness | 15 | Core, theme API, page types, density, storytelling, production, and acceptance contracts cover the intended portfolio. |
| Safety and portability | 10 | No factual fabrication, brand copying, destructive behavior, proprietary font assumption, model pinning, or legacy overwrite. |
| Maintainability | 5 | Names and paths are consistent, docs avoid contradiction, validation errors are actionable, and extension points are clear. |

## Scoring

Award integer points only. Every deduction cites a file and exact missing or contradictory behavior.
Do not give full credit based on intent. Run the validator and inspect each configured path.

## Hard blockers

- Invalid JSON, TOML, YAML frontmatter, or missing referenced file
- Validator cannot run in the current Windows workspace
- No durable project memory or no Codex-discoverable build skill
- Writer approves its own work or reviewer has write authority
- Hook attempts subjective design judgment or creates an unbounded Stop loop
- Common core contains company-specific branding or proprietary assets
- No deterministic-fail → architect-fix → independent-recheck loop
- Acceptance is described as a statistical 97% accuracy claim

## Passing floors

Both independent reviewers must score at least 97/100; hard blockers must be zero. Architecture,
Skill actionability, and Validation may each lose at most one point; Agent independence must be
15/15; Safety must be 10/10. The lower accepted score is final.
