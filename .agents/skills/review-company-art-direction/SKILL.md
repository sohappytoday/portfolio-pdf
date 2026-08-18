---
name: review-company-art-direction
description: Independently audit a company art-direction extraction for evidence traceability, synthesis quality, font and brand safety, and readiness for the portfolio theme contract. Use after extract-company-art-direction, when reviewing a company's research package, or when deciding whether an extraction meets the 97/100 handoff threshold. Reviewers are strictly read-only and never fix the artifact they score.
---

# Review company art direction

Review the exact extraction snapshot; do not edit it.

## Required reading

Read `AGENTS.md`, `portfolio-system/ART_DIRECTION_CONTRACT.md`,
`portfolio-system/THEME_CONTRACT.md`, `portfolio-system/art-direction.schema.json`, and
`portfolio-system/art-direction-review.schema.json`, `portfolio-system/art-direction-acceptance.schema.json`,
and `references/art-direction-quality-rubric.md` before scoring.

## Procedure

1. Run the extraction validator for the target slug without `-RequireAcceptance`.
2. Compute the SHA-256 of `art-direction.json` and identify the snapshot in the report.
3. Verify cited evidence IDs in both JSON and `sources.md`; spot-check URLs, access dates, methods, source
   roles, observations, inferences, confidence, and license evidence. Browsing is required for a real review
   because sources and license pages can change.
4. Check hard blockers and score caps before awarding category points.
5. Score every category with file path, JSON field or evidence ID, and a concrete deduction reason. Use whole
   numbers and never round up.
6. Remain read-only. Return a structured review to the coordinator. Do not create `acceptance.json` and do
   not fix the artifact.

Two independent reviewers evaluate the same hash. Each must score at least 97, each critical category must
meet its floor, and neither may report a hard blocker. Use the lower total. If totals differ by more than two
points, or any category differs by more than one point, request a third read-only adjudicator.

The coordinator stores each returned report verbatim under the extraction's `reviews/` directory, then may
write `acceptance.json` matching the acceptance schema: exact artifact hash, each
reviewer's same hash, designated distinct role, seven category scores, recomputable total and floors, score
cap, report path and hash, empty hard blockers, conservative lower final score, and `PASS`. Any change to `art-direction.json`
invalidates that acceptance and requires two new reviews.

## Report format

Return one JSON object matching `art-direction-review.schema.json`. A minimal shape is:

```json
{
  "schemaVersion": "1.0.0",
  "scope": "art-direction-handoff",
  "artifactSha256": "<64 lowercase hex characters>",
  "reviewedAt": "YYYY-MM-DD",
  "role": "company_art_direction_evidence_verifier",
  "totalScore": 97,
  "categoryScores": {
    "evidence": 19,
    "synthesis": 17,
    "typography": 15,
    "visualLanguage": 15,
    "brandSafety": 12,
    "themeHandoff": 12,
    "uncertainty": 7
  },
  "categoryFloorsPass": true,
  "scoreCap": null,
  "hardBlockers": [],
  "verdict": "PASS",
  "findings": [
    { "category": "evidence", "evidence": "path, field, or evidence ID", "deduction": "reason or empty string" }
  ]
}
```

Use `findings` for unsupported/conflicting claims, typography rights and Korean support, brand distance,
theme handoff, and required fixes. State in a finding that the result approves only research handoff readiness,
not the final theme or rendered portfolio.
