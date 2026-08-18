---
name: apply-company-art-direction
description: Apply an accepted company art direction as a licensed, company-specific theme adapter, prove it against the common fixtures, and render an immutable portfolio build when company-neutral layouts exist. Use after extract-company-art-direction has a hash-matching PASS. Do not research a company, rewrite content, or modify the common core during application.
---

# Apply company art direction

Translate an accepted research handoff into an offline, reproducible company theme and immutable rendered
evidence. Preserve the common core, facts, semantic DOM, and every legacy output byte.

## Required reading

Read, in order:

1. `AGENTS.md`
2. `.agents/memory/portfolio-system-strategy.md`
3. `portfolio-system/APPLICATION_CONTRACT.md`
4. `portfolio-system/ART_DIRECTION_CONTRACT.md`
5. `portfolio-system/THEME_CONTRACT.md`
6. `portfolio-system/PAGE_TYPES.md`
7. `portfolio-system/QUALITY_GATE.md`
8. `portfolio-system/theme-application.schema.json`
9. `portfolio-system/font-license.schema.json`
10. `references/application-protocol.md`

Use `$review-applied-portfolio` after rendering. A writer never approves its own build.

## Inputs and mode

Require a company slug and accepted extraction. Run the extraction validator with `-RequireAcceptance`
before any application write. Never manufacture missing candidates or silently refresh research.

Choose one mode:

- `adapter-proof` when `result/layout/` is absent or the user only needs theme-system validation;
- `portfolio-render` only when `result/layout/` contains one company-neutral HTML file for every
  `result/content/NN-slug.md` and the inventory matches `page-map.json`.

If portfolio layouts are missing, continue only as adapter-proof and report the final portfolio render as
blocked. Do not use legacy company HTML as a template and do not create company-specific DOM.

## Workflow

1. Validate accepted research and capture an application input baseline. Inspect existing
   `designs/<slug>/application/` and `result/design/<slug>/`; never overwrite either. A revision uses a new
   application version or build ID. Existing top-level legacy PDFs/pages remain untouched.
2. Use `company_theme_applier` as the sole source writer. It writes only:
   - `designs/<slug>/application/adapter.css`;
   - `designs/<slug>/application/theme-manifest.json`;
   - `designs/<slug>/application/font-license.json`;
   - licensed local static font files listed by the font manifest.
3. Map all 21 required variables. Record each final value, accepted evidence IDs, derivation, and rationale.
   Accessibility adjustments and licensed substitutions are explicit. Do not copy production CSS or assets.
4. Run `scripts/validate-application.ps1 -RepoRoot <repo> -CompanySlug <slug>`. Fix every source failure before
   launching Chrome.
5. Render with `node scripts/render-application.mjs --repo-root <repo> --company-slug <slug>
   --build-id <unique-id>`. Add `--require-pdf-tools` for any build intended for portfolio-render acceptance.
   The renderer uses a disposable Chrome/Edge profile, a new staging directory, local assets only, and the
   same loaded page for DOM audit, screenshot, and PDF capture.
6. Run the validator again with `-BuildId <id>`. A partial or production-ineligible build is not review-ready.
7. Invoke `$review-applied-portfolio`. Store returned schema-valid reviewer JSON verbatim in the build's
   `reviews/`. Two designated read-only roles inspect the same input-lock, preflight, output-set, PNGs, and PDFs.
8. If both reviewers pass and no adjudicator is required, the coordinator writes build `acceptance.json`,
   then runs the validator with `-BuildId <id> -RequireAcceptance`.
9. Only after that passes may the coordinator create or update `current.json` to point at the accepted build.
   Do not mirror files over legacy top-level output without separate explicit migration authority.

## Guardrails

- Application source writes only under `designs/<slug>/application/`; rendering writes only a new staging
  and build directory for that slug.
- Treat `content/`, `result/content/`, `result/layout/`, `portfolio-system/`, `.claude/`, extraction research,
  and every existing build or legacy output as read-only.
- No remote URL, `@import`, data-URI asset, variable font, page-ID selector, page-number selector, generated
  text via CSS `content`, company logo, slogan, mascot, screenshot, or production selector.
- Missing Chrome/Edge may block rendering. Missing `pdftotext`, `pdfinfo`, or `pdffonts` blocks production
  acceptance; it is never downgraded to a warning when `portfolio-render` is claimed.
- Overflow, broken glyph, unexpected fallback, missing page, mismatched output hash, stale input lock, or a
  reviewer below 97 is a hard stop. Do not average or round up.

## Completion report

Report mode, source package, build ID/path, input-lock and preflight hashes, production eligibility, reviewer
scores, lower final score, current-pointer status, blocked prerequisites, and exact next action. Distinguish
adapter-proof readiness from final rendered-portfolio approval.

