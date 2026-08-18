# Company art-direction application contract

Version: 1.0.0

## Purpose

This contract applies an independently accepted company art direction to the company-neutral portfolio
system without changing facts, semantic page structure, or common-core behavior. It distinguishes authored
theme source from immutable rendered builds and never treats fixture success as final portfolio approval.

## Inputs

Application may start only when all of the following are true:

- `designs/<slug>/research/art-direction/acceptance.json` is a hash-matching `PASS` and the extraction
  validator passes with `-RequireAcceptance`;
- the current `SYSTEM.md`, `THEME_CONTRACT.md`, `core.css`, `page-map.json`, and `result/content/` inventory
  are captured in a new application input lock;
- all 21 required theme candidates remain traceable to accepted evidence;
- selected fonts have local static files plus verified license, Korean glyph, and PDF-embedding evidence;
- no company logo, wordmark, mascot, slogan, screenshot, production CSS, proprietary illustration, or
  unlicensed font is required.

The application input lock is distinct from extraction acceptance. It fingerprints the exact research,
system, content, adapter, fonts, and renderer used by a build while excluding the build's own output path.

## Source and output boundaries

Authored company-theme source:

```text
designs/<slug>/application/
  adapter.css
  theme-manifest.json
  font-license.json
  fonts/*                    licensed local static font files only
```

Immutable generated build:

```text
result/design/<slug>/builds/<build-id>/
  inputs.lock.json
  pages/theme.css
  pages/fonts/*
  fixtures/*.html|png|pdf
  pages/NN-slug.html|png|pdf       portfolio-render mode only
  portfolio-N.pdf                 portfolio-render mode only
  preflight.json
  reviews/*.json
  acceptance.json
```

`result/design/<slug>/current.json` may point to an accepted build. It does not authorize moving, deleting,
or overwriting legacy top-level output. A build ID is immutable: if its directory already exists, create a
new build ID.

## Two honest modes

- `adapter-proof`: compile `core.css + adapter.css` and render the unchanged sparse and dense fixtures. This
  can prove theme-contract compatibility, font loading, basic density behavior, and transformation distance.
  It cannot approve the final portfolio.
- `portfolio-render`: additionally requires a complete company-neutral semantic layout set under
  `result/layout/`, one HTML file for every `result/content/NN-slug.md`. Layout files are shared across
  companies and may be created only through the common-system workflow. Applying a theme never edits them.

If `result/layout/` is missing or incomplete, application may finish as `adapter-proof`; it must report the
portfolio render as blocked and must not synthesize company-specific DOM from legacy output. Existing Toss
HTML/CSS predates this contract and is regression-protected, not a template.

## Adapter rules

`adapter.css` defines every required `--theme-*` variable exactly once on `:root`. It may define local static
`@font-face` rules and explicitly declared `.theme-*` modifier classes allowed by `THEME_CONTRACT.md`.
It may not use remote URLs, `@import`, data-URI assets, page-ID selectors, page-number selectors, copied
production selectors, or structural rules that change the semantic DOM. Accessibility adjustments and
licensed font substitutions are recorded in `theme-manifest.json`; silent fallback is forbidden.

## State and gates

Application source uses `blocked | adapter-ready | portfolio-ready`. A rendered build progresses through:

```text
rendered -> review-ready -> accepted
```

Any input drift makes the build `stale`. Missing renderer, missing PDF-text tooling for a production claim,
font uncertainty, overflow, missing page, or broken glyph makes it `blocked`, not partially accepted.

Every build must prove:

- input-lock hashes still match before rendering and before acceptance;
- fixture DOM sources are unchanged and sparse/dense both render at 1280x720;
- portfolio-render page names, order, count, page types, and densities match `result/content/` and
  `page-map.json` one-to-one;
- each HTML/PNG/PDF and final numbered PDF exists, is nonempty, and is hash-recorded;
- overflow checks pass and configured text probes remain selectable in the PDFs;
- copied fonts match `font-license.json`, are static, local, Korean-capable, and embedding-permitted.

## Independent acceptance

Two read-only reviewers inspect the same input lock, preflight, PNG/PDF set, and output-set hash. One focuses
on contract/production evidence and one on rendered visual quality. Each must score at least 90/100, meet all
`QUALITY_GATE.md` category floors, and report no hard blocker. A total difference above two points or category
difference above one point requires a third read-only adjudicator. The conservative minimum remains final.

Adapter-proof acceptance has scope `adapter-proof` and only approves safe theme handoff to the common system.
Portfolio-render acceptance has scope `portfolio-render` and may approve that exact rendered build. Neither
scope approves factual changes, company affiliation, or reuse of protected brand assets.

### Focused visual review

An early single-page or partial-build review may use the `focused-build` profile from `QUALITY_GATE.md` when
the requester explicitly names the categories to include. It is diagnostic only: excluded categories are
not scored, reviewers record the selection evidence, and the resulting report is never acceptance-eligible.
Only the `full-portfolio` profile can create `acceptance.json` or advance `current.json`.
