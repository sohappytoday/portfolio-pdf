# Application protocol

## Adapter source

`adapter.css` contains local static `@font-face` declarations, one `:root` block with every required theme
variable exactly once, and only the modifier classes declared in `theme-manifest.json`. The compiled build
stylesheet is exact common-core bytes, a visible delimiter comment, and exact adapter bytes in that order.
Never edit the compiled file as source.

Selected font families must appear in `font-license.json`. Every font file stays below
`designs/<slug>/application/fonts/`, has a matching SHA-256, uses a single static weight, and is copied into
the build. A license URL is evidence, not permission by assertion; the reviewer verifies it.

## Company-neutral layout prerequisite

`result/layout/NN-slug/NN-slug.html` is shared semantic DOM. It is owned by the common-system workflow, maps one-to-one
to `result/content/NN-slug.md`, links only its sibling `theme.css`, and declares `data-page-type`, `data-density`, and page
number. Each file provides one or more `<meta name="pdf-text-probe" content="...">` values copied exactly from
its content source for PDF text verification.

Application never adds, removes, or rearranges layout nodes for a company. When a direction cannot work with
the neutral layout, return a cited common-system defect to `$build-common-portfolio-system`; do not patch the
layout inside the company pass.

## Build identity

Use a readable unique ID such as `20260818-toss-v1`. A build ID cannot be reused. The renderer first validates
source, writes to `result/design/<slug>/.staging/<build-id>/`, records every input/output hash, and moves the
completed preview to `builds/<build-id>/`. It never deletes stale staging or an existing build automatically.

`inputs.lock.json` binds accepted research, extraction acceptance, system manifest, core, theme contract,
page map, combined content, adapter, font manifest, renderer, and each page/layout. Input drift before the
build completes makes the preflight ineligible.

## Adapter-proof versus portfolio-render

Adapter-proof renders neutral and company variants of the same sparse/dense fixture DOM. Review checks theme
contract coverage, transformation distance, both density extremes, fonts, offline resources, and visual
coherence. Its acceptance cannot be used as a final PDF claim.

Portfolio-render adds all neutral layout pages. Production eligibility requires all declared PDF inspection
tools, selectable text probes, one-page PDF geometry, complete page inventory, font evidence, zero overflow,
and exact output hashes. Every PNG and PDF is reviewed before source CSS.

## Failure behavior

- Missing/stale extraction acceptance: stop before source write.
- Missing candidate: return to extraction; never substitute neutral values silently.
- Missing or incomplete layout: adapter-proof only.
- Unlicensed/variable/missing font: blocked.
- Existing source directory/build ID: preserve it and choose a new version/ID.
- Renderer or production PDF tools unavailable: preserve diagnostics, no acceptance/current pointer.
- Review failure: keep immutable build evidence, create a new source revision and new build ID after fixes.
