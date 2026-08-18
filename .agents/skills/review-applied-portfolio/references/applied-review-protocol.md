# Applied build review protocol

Use the weights and floors in `QUALITY_GATE.md`:

| Category | Points | PASS floor |
|---|---:|---:|
| typography | 25 | 24 |
| layout | 20 | 19 |
| hierarchy | 15 | 14 |
| storytelling | 15 | 14 |
| adaptability | 15 | 14 |
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
