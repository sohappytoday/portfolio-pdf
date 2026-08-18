---
name: review-applied-portfolio
description: Independently review an applied company-theme build against its input lock, deterministic preflight, rendered PNG/PDF evidence, brand-safety constraints, and the 97-point quality gate. Use after apply-company-art-direction creates an immutable build. Reviewers are read-only and never repair the build they score.
---

# Review applied portfolio

Review one immutable build snapshot. Never edit it.

## Required reading

Read `AGENTS.md`, `portfolio-system/APPLICATION_CONTRACT.md`, `portfolio-system/QUALITY_GATE.md`,
`portfolio-system/application-review.schema.json`, `portfolio-system/application-acceptance.schema.json`,
and `references/applied-review-protocol.md`.

## Procedure

1. Run the application validator with the exact company slug and build ID, without acceptance.
2. Verify `inputs.lock.json`, `preflight.json`, and every output hash. Reject a stale or production-ineligible
   portfolio-render build before aesthetic scoring.
3. Inspect all PNGs and PDFs before CSS. Adapter-proof compares neutral/company sparse and dense fixtures.
   Portfolio-render inspects every page for typography, layout, hierarchy, storytelling, brand fit, detail,
   glyphs, overflow, and cross-page consistency.
4. Run `applied_theme_contract_verifier` and `applied_portfolio_visual_verifier` independently against the same
   hashes. Each returns one JSON object matching `application-review.schema.json`.
5. If totals differ by more than two or a category by more than one, run
   `applied_portfolio_adjudicator`. Reviewers remain read-only.
6. The coordinator stores reports verbatim and may write acceptance only when each reviewer is at least 97,
   every category floor passes, hard blockers are zero, and all report/build hashes match.

Adapter-proof uses the same 100-point categories but cannot receive Production 5/5 without full page/PDF
evidence; its verdict explicitly covers theme handoff only. Portfolio-render uses `QUALITY_GATE.md` literally.
The lower recorded score is final and no adjudicator may rescue a reviewer below 97.

## Output

Return schema-valid JSON with exact scope, company/build IDs, input-lock/preflight/output-set hashes, designated
role, seven category scores, floor result, blockers, verdict, and page/fixture-specific findings. A PASS states
whether it approves adapter-proof or the exact rendered portfolio build.

