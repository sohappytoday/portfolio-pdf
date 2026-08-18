---
name: build-common-portfolio-system
description: Build or revise the company-neutral portfolio design system under portfolio-system/, including layout, typography roles, page types, visual-storytelling components, theme boundaries, and deterministic QA. Use when creating the reusable portfolio foundation, improving system-level design quality, separating common CSS from a company theme, or preparing the portfolio for multiple company-specific art directions. Do not use for editing factual content or for researching one company's brand.
---

# Build common portfolio system

Create a reusable visual core that can accept distinctly different company themes without changing facts or page structure.

## Required reading

Read, in order:

1. `.agents/memory/portfolio-system-strategy.md`
2. `portfolio-system/SYSTEM.md`
3. `portfolio-system/THEME_CONTRACT.md`
4. `portfolio-system/PAGE_TYPES.md`
5. `portfolio-system/QUALITY_GATE.md`
6. `references/build-protocol.md`

Also inventory `result/content/` and any current company output. Reuse proven rendering knowledge; do not
overwrite existing rendered output.

## Workflow

1. Establish scope. List the system files to change and the invariant each change serves. Treat content and company research as read-only. When full portfolio rendering is in scope, this workflow alone may create or revise the company-neutral `result/layout/NN-slug/NN-slug.html` set.
2. Run parallel read-only discovery when useful: current-output audit, typography/license audit, and page-type/density audit. Do not run parallel writers.
3. Give `portfolio_system_architect` sole ownership of edits for the pass, or act as the sole writer if that custom agent is unavailable.
4. Preserve the core/theme boundary. Core selectors may consume `--theme-*` variables but may not contain a company name, logo, proprietary font, or company-only component.
5. Cover every required page type and state in `PAGE_TYPES.md`. Prefer semantic components such as stat, comparison, timeline, flow, architecture, evidence, and quote over repeated generic cards.
   Neutral layout files must map one-to-one to `result/content/`, link `theme.css`, expose page type/density/number metadata, and remain identical across company themes.
6. On Windows, run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/build-common-portfolio-system/scripts/validate-portfolio-system.ps1 -RepoRoot <git-root>`. On PowerShell 7, `pwsh -NoProfile -File ...` is also valid. Fix every deterministic failure.
7. Render the sparse/dense fixtures with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/build-common-portfolio-system/scripts/render-system-fixtures.ps1 -RepoRoot <git-root> -ProtectedPath result/design`. Use `-RequirePdfTextTools` for a production-eligible gate; without it, unavailable PDF text tools must be reported as unverified.
8. Invoke `$review-portfolio-system`. Keep reviewers read-only. Route cited failures back to the architect and repeat until the gate passes or a genuine external blocker is documented.

## Deliverable report

Report changed contracts/components, deterministic results, both independent scores, the lower final score, remaining blockers, and the exact next workflow. Never call the number a probability or scientific accuracy.

## Guardrails

- Do not edit `content/` or invent portfolio claims.
- Do not bake a target-company color, font, logo, slogan, or copied CSS into `portfolio-system/core.css`.
- Do not accept a screenshot-only pass: PDF text selection, glyphs, page size, and font behavior also matter.
- Do not let a reviewer fix its own findings.
- Do not derive neutral layouts from legacy company HTML or introduce a company-specific selector/asset into `result/layout/`.
