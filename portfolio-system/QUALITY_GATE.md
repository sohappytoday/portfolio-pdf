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

Hard blockers: zero. Both independent reviewers: at least 97/100. Floors: Typography 24/25, Layout 19/20,
Hierarchy 14/15, Storytelling 14/15, Adaptability 14/15, Detail 4/5, Production 5/5. The lower reviewer
score is final. Differences above two total points or one category point require a third adjudicator.
