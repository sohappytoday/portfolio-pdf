# Rendered portfolio quality gate — 100 points

This is an operational acceptance rubric, not a statistical accuracy estimate. Score from final PDF and
page PNGs first; inspect source only afterward. Every deduction cites a page and concrete evidence.

| Category | Points | Required evidence |
|---|---:|---|
| Typography | 25 | license/Korean support 5; scale 5; line height/measure 5; mixed-script/numerals 4; fallback/glyph stability 3; optical detail 3 |
| Layout and spacing | 20 | grid/margins 5; rhythm 5; whitespace/density 4; alignment/geometry 3; dense-page handling 3 |
| Information hierarchy | 15 | three-second comprehension 4; role consistency 4; focal order 4; navigation/progression 3 |
| Visual storytelling | 15 | problem-action-result 4; evidence visualization 4; page-type choice 3; image/caption contribution 2; pacing 2 |
| Brand adaptability | 15 | core/theme separation 4; theme swap integrity 4; three-theme distinction 3; asset/font fallback 2; fit without imitation 2 |
| Detail and consistency | 5 | line/radius/icon/caption unity 2; chrome/numbering/metadata 2; optical finish 1 |
| Production QA | 5 | PDF format 2; fonts/selectable text/links 1; image/color quality 1; reproducible preflight 1 |

## Hard blockers

Any blocker fails the artifact regardless of score: broken or missing PDF/page; clipping, overlap, or
overflow; broken glyph or unexpected fallback; unlicensed asset; unreadable body contrast or undersized
body text; inconsistent page geometry; broken asset/link; company-specific values in core; theme swap
requiring content/structure edits; fabricated result; or preflight evidence from a different build.

Production evidence comes from the same snapshot's `preflight.json` and `font-license.json`. A renderer
may report missing `pdftotext`/equivalent tooling as `unavailable`, but that snapshot is not eligible for
Production QA 5/5 until it is rerun with `-RequirePdfTextTools` in an environment that can verify selectable
text and glyphs. Protected legacy/company output must have matching before/after fingerprints.

## Passing rule

Hard blockers: zero. Both independent reviewers: at least 90/100. Floors: Typography 22/25, Layout 18/20,
Hierarchy 13/15, Storytelling 13/15, Adaptability 13/15, Detail 4/5, Production 5/5. The lower reviewer
score is final. Differences above two total points or one category point require a third adjudicator.

## Optional review profiles

`full-portfolio` is the only profile that can approve a build. It always scores all seven categories and
uses the passing rule above.

`focused-build` is a diagnostic profile for an explicitly scoped design iteration, such as a single cover
page. It always includes Typography, Information hierarchy, Detail and Production. Layout is included only
when the requester explicitly asks for it and the reviewer has a final rendered page with grid, margin,
spacing and overflow evidence. It may include Storytelling only with at least three sequential portfolio
pages and page-specific problem-to-action-to-outcome evidence. It may include Adaptability only with the
same semantic layouts rendered neutrally and through two distinct, licensed theme adapters.

Unselected categories are recorded as `null`, listed in `notAssessedCategories`, and never treated as zero.
The review score is normalized to the selected categories' available points. A focused-build report must set
`acceptanceEligible` to `false`; it can guide a revision, but it cannot produce `acceptance.json` or update
`current.json`.
