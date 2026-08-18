# Build protocol

## Inputs

- Required: `result/content/NN-slug.md` page inventory and the contracts under `portfolio-system/`.
- Optional evidence: current `result/design/<company>/pages/*.png`, `theme.css`, reference analysis, and company research.
- Out of scope: factual rewriting, job-fit content scoring, and company research.

## Stable core responsibilities

The core owns canvas, safe area, grid, spacing, type roles, density modes, page chrome, focus order,
component geometry, accessibility defaults, print behavior, and semantic component APIs.

The company adapter owns only values and expressive variants allowed by `THEME_CONTRACT.md`.
If an adapter needs new structural markup to work, treat that as a core-contract defect and resolve it in the core first.

## Change sequence

1. Record the observed problem with a file/page reference.
2. Name the system invariant that is missing or violated.
3. Change the smallest shared primitive or component that fixes the class of problem.
4. Update `portfolio-system/page-map.json` if page files or their system-level type/density assignments changed. Do not put this metadata into factual content.
5. Test `fixtures/sparse.html` and `fixtures/dense.html` under every manifest theme. The renderer changes stylesheets only; fixture DOM and copy remain identical.
6. Pass `-ProtectedPath` to the renderer for existing company output that must remain untouched. The preflight must contain equal before/after SHA-256 fingerprints.
7. Run deterministic validation, render preflight, then independent visual review. Existing Toss pages are regression-protected legacy evidence, not proof that the new common core rendered correctly.

## Evidence standard

A passing claim includes the command or review method, the exact artifact, and the result. “Looks
good” is not evidence. A visual deduction cites the PNG/PDF page and the violated rubric item.
