# Portfolio PDF workspace

## Durable context

Before changing the portfolio architecture, read `.agents/memory/portfolio-system-strategy.md`.
That file is the project-scoped memory for the common-system and company-art-direction strategy.

## Source boundaries

- `content/` contains user-authored facts. Never invent or silently rewrite facts.
- `result/content/` is the company-neutral, page-level content source.
- `result/layout/` is the optional company-neutral semantic HTML layer. It is owned by the common-system
  workflow and must map one-to-one to `result/content/` before a full company render is allowed.
- `portfolio-system/` is the reusable visual core and its contracts.
- `designs/<company>/research/art-direction/` is the canonical company art-direction extraction package.
- `designs/<company>/application/` contains the authored company adapter, font/license evidence, and its
  source manifest. It never owns page structure.
- Other files in `designs/<company>/research/` are legacy notes or raw inputs and are never silently overwritten.
- `result/design/<company>/` contains company-specific rendered output.

## Required workflows

Use `$build-common-portfolio-system` when creating or changing the reusable visual core. Use
`$review-portfolio-system` for independent acceptance review. A writer must not approve its own work.
Run deterministic validation before requesting visual review.

Use `$extract-company-art-direction` for current, evidence-backed company research and
`$review-company-art-direction` for independent extraction acceptance. Extraction writes only under
`designs/<slug>/research/art-direction/`; it does not create CSS or modify the common system, content, or
rendered output. Use `$apply-company-art-direction` only after a hash-matching `PASS` acceptance, and use
`$review-applied-portfolio` for its independent acceptance. Full portfolio rendering additionally requires
the company-neutral `result/layout/` set; legacy company HTML is not a template.

The acceptance threshold is an operational rubric score, not a statistical accuracy claim:
all deterministic checks pass, no hard blocker exists, and each independent reviewer scores at
least 97/100. Use the lower reviewer score as the final score.

## Working rules

- Keep common system and company theme separate; target roughly 70% stable core and 30% art direction.
- Run parallel agents for research or read-only review only. Keep one writer at a time.
- Hooks enforce deterministic checks only. Typography taste, hierarchy, and visual quality require agents viewing rendered output.
- Preserve text selection, Korean glyphs, font licensing, 1280x720 page consistency, and one-to-one page numbering.
- Never copy company logos, proprietary fonts, mascots, slogans, or production CSS as portfolio assets.
