# Applied build review protocol

Use the weights and floors in `QUALITY_GATE.md`:

| Category | Points | PASS floor |
|---|---:|---:|
| typography | 25 | 22 |
| layout | 20 | 18 |
| hierarchy | 15 | 13 |
| storytelling | 15 | 13 |
| adaptability | 15 | 13 |
| detail | 5 | 4 |
| production | 5 | 5 |

Check hard blockers before scoring. Every deduction identifies a PNG/PDF page or fixture plus the exact
contract/preflight field. Reviewers do not trust manifest booleans without inspecting the referenced artifact.

For adapter-proof, Production 5/5 means the exact fixture build is reproducible, offline, 1280x720,
text-selectable, hash-bound, and font/license verified. It does not imply final-portfolio production approval.
Compare neutral and company versions of sparse/dense fixtures and state that no final portfolio is approved.
For portfolio-render, inspect the complete
page sequence, verify pacing and repeated-layout risk across pages, then inspect CSS/font/source evidence.

Required blockers include stale hashes, incomplete output inventory, overflow, clipping, broken glyphs,
unexpected font fallback, unreadable contrast, remote/restricted assets, copied company UI, company-specific
core changes, semantic DOM/content drift, missing production tools, or evidence from different build hashes.

## Profile selection

| Profile | Included categories | Extra eligibility evidence | Acceptance |
|---|---|---|---|
| `full-portfolio` | all seven | complete intended portfolio sequence | eligible |
| `focused-build` | typography, hierarchy, detail, production; `layout` only if requested | a final rendered page for layout | never eligible |
| `focused-build` + storytelling | baseline plus storytelling | 3+ ordered pages with problem-action-outcome evidence | never eligible |
| `focused-build` + adaptability | baseline plus adaptability | neutral render plus two licensed adapters from identical semantic DOM | never eligible |

The requester must explicitly name `focused-build` and each optional category. If they do not, use
`full-portfolio`. `storytelling` and `adaptability` stay unassessed when their evidence conditions are absent,
even if requested. Reports partition all seven categories into `includedCategories` and
`notAssessedCategories`; unassessed category scores are `null`. Calculate `totalScore` as the rounded
percentage of earned/available selected points, and calculate floors only for selected categories.
