# Common portfolio system contract

Version: 1.0.0

## Purpose

This directory defines the company-neutral visual grammar for every portfolio. It stabilizes reading,
storytelling, and PDF production while leaving enough expressive range for a target-company art direction.

## Composition

```text
result/content/NN-slug.md
        +
portfolio-system/core.css                 stable behavior and components
        +
result/layout/NN-slug/NN-slug.html        optional neutral semantic DOM + page-local preview assets
        +
designs/<company>/research/art-direction/ accepted evidence-backed decisions
        +
designs/<company>/application/adapter.css authored company expression
        ->
result/design/<company>/builds/<build-id>/pages/theme.css
        -> immutable HTML + PNG + PDF evidence
```

A generated `theme.css` may concatenate core and adapter for reliable local PDF rendering. The source
boundary remains explicit even when delivery bundles them into one file.

Company research follows `ART_DIRECTION_CONTRACT.md`. The extraction workflow produces no CSS. The
application workflow follows `APPLICATION_CONTRACT.md` and may consume only a hash-matching `PASS`
acceptance for `art-direction.json`. Fixture-only adapter proof is distinct from final portfolio approval.

Existing company outputs that predate this contract are regression-protected legacy artifacts. They do
not prove that a new core change works. Proof comes from the manifest fixtures first, then from a company
output explicitly migrated to this contract.

## Core invariants

- Canvas: 1280 by 720 CSS pixels, landscape, zero print margin.
- Safe area: 64px minimum on every edge; page chrome aligns to the same grid.
- Grid: 12 columns with 24px gutters; components span deliberate column counts.
- Type: at least six semantic roles with Korean-safe fallback and fixed static weights for final PDF fonts.
- Rhythm: a shared spacing scale; related gaps are smaller than section gaps.
- Focus: one dominant idea per page, visible in a three-second scan.
- Storytelling: processes, comparisons, architectures, and metrics use semantic visual forms.
- Production: selectable text, consistent page dimensions, no overflow, no missing glyphs or assets.

## System metadata and evidence

`page-map.json` owns system-level `type` and `density` for every *currently active*
`result/content/NN-slug.md`; factual content stays untouched. During incremental design work, this may be
a one-page inventory. Add or remove page-map entries together with the corresponding content files; do not
reserve entries for planned pages. A full company render is allowed only when this live inventory represents
the intended portfolio and every entry has a one-to-one neutral layout. Fixture output is generated under `portfolio-system/.generated/<snapshot>/`
and is not a source file. Its `preflight.json` records source hashes, protected-path before/after hashes,
rendered file checks, image dimensions, PDF text-tool availability, and production-gate eligibility.

Once `result/layout/` contains a numbered layout, deterministic validation requires one matching layout for
every currently active content page. This deliberately fails when content is added without its page-map entry
and neutral layout, so an incremental build cannot silently drift out of sync.

A final company bundle also records font evidence in `font-license.json`: family, source, license name,
license URL or local license file, embedded static weights, Korean glyph support, and fallback. Missing
font evidence or unavailable PDF text extraction prevents Production QA 5/5; it is never silently assumed.

`result/layout/` is optional until a full portfolio render is requested. When present, it is common-system
source: one semantic HTML file per content page, independent of any company theme. It is never inferred from
legacy company output during an application pass.

## Ownership boundary

The core owns structure and behavior. A company theme implements `THEME_CONTRACT.md` and may change
expression only. A theme may not require changes to factual content, page ordering, or semantic markup.

## Change policy

Breaking changes require a manifest version increase and an explicit migration note. A component is added
to the core only when it represents a recurring information need across companies, not a one-company motif.
Every change must pass deterministic validation and independent review.
