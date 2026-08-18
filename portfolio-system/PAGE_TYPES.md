# Page type contract

Each page has one primary type and one density (`sparse`, `balanced`, or `dense`) in
`portfolio-system/page-map.json`. This keeps design metadata out of factual `result/content/` files.
Generated HTML mirrors the mapping as `data-page-type` and `data-density` on `.page`. Page types guide
composition without forcing identical templates.

| Type | Primary job | Required focal form | Avoid |
|---|---|---|---|
| cover | Establish candidate and positioning | display statement plus restrained metadata | generic centered title slide |
| profile | Make strengths scannable | concise thesis plus evidence anchors | biography wall |
| capability | Show skill systems and depth | grouped capability map | logo cloud or keyword dump |
| experience | Show progression and ownership | timeline or editorial sequence | equal-weight card grid |
| project-opener | Set problem, role, and stakes | strong project thesis or visual field | miniature detail page |
| architecture | Explain system relationships | connected diagram with legend | prose boxes pretending to be a diagram |
| process | Explain decisions over time | flow, sequence, or decision tree | long numbered paragraphs |
| troubleshooting | Show diagnosis and judgment | signal-to-cause-to-fix chain | incident text dump |
| result | Prove outcomes | dominant verified metrics with context | unsupported vanity numbers |
| closing | Leave a coherent final signal | distilled positioning and contact | repeated cover |

## Density rules

- Sparse: one focal statement; no more than two supporting groups.
- Balanced: one focal element plus two to four supporting groups.
- Dense: one visual model plus compact labels; never reduce body text below 15px to force fit.
- Keep ordinary body lines near 45–75 Latin characters or an equivalent comfortable Korean measure.
- If content cannot fit without clipping or microscopic type, return to page planning; do not conceal overflow.

## Composition rule

Adjacent pages should share tokens and chrome but vary composition. Repeating the same card grid is not
consistency. Every metric, comparison, timeline, flow, or architecture claim should trigger the matching
semantic visual component when the source evidence supports it.
