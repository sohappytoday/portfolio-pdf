# Art-direction extraction quality rubric

This is a 100-point operational rubric, not a probability or statistical accuracy measure.

## Scoring

| Category | Points | Minimum for PASS |
|---|---:|---:|
| Source quality and evidence traceability | 20 | 18 |
| Art-direction synthesis | 18 | 16 |
| Typography and font safety | 15 | 14 |
| Visual-language specification | 15 | 13 |
| Originality and brand safety | 12 | 12 |
| Theme-contract handoff readiness | 12 | 12 |
| Uncertainty and decision record | 8 | 7 |
| Total | 100 | 90 |

### Source quality and evidence traceability — 20

- 6: required official contexts, source roles, current access dates, and canonical target are sound.
- 4: at least two genuinely rendered or official-screenshot contexts support visual claims.
- 6: every material claim and decision resolves through stable evidence IDs in JSON and `sources.md`.
- 4: currentness, cross-checks, access limitations, and source conflicts are explicit.

### Art-direction synthesis — 18

- 6: three to five coherent principles follow observation -> abstraction -> portfolio decision.
- 5: principles become specific portfolio grammar, not adjective lists or interface imitation.
- 4: target role, reader, region, and relevant surface weighting influence decisions.
- 3: concrete use/avoid guidance and rejected alternatives are explained.

### Typography and font safety — 15

- 5: license and PDF-embedding rights are evidenced for each selected alternative.
- 4: Korean glyph and Korean/Latin/numeric support are verified.
- 3: roles, weights, hierarchy, numerals, and fallbacks are implementable.
- 3: observed proprietary fonts are separated and never selected as candidates.

### Visual-language specification — 15

- 4: semantic color relationships, accessibility intent, and confidence are clear.
- 4: type, shape, line, surface, elevation, and density form a coherent system.
- 4: imagery, iconography, data visualization, and verbal tone are actionable.
- 3: all required semantic theme candidates have value, rationale, confidence, and evidence IDs.

### Originality and brand safety — 12

- 4: restricted assets and forbidden patterns are complete.
- 5: observed brand signals are abstracted with sufficient transformation distance.
- 3: rights, source use, trademark confusion, and non-affiliation risk are controlled.

### Theme-contract handoff readiness — 12

- 4: every `THEME_CONTRACT.md` variable has a candidate with traceable metadata.
- 4: candidates can be applied without changing facts, semantic DOM, page order, or common core.
- 4: page-type guidance is complete and gives the future apply workflow testable choices and guardrails.

This category does not score rendered quality. Fixture, contrast, overflow, glyph, and PDF evidence belong to
the later application workflow; extraction acceptance must never be presented as final-design approval.

### Uncertainty and decision record — 8

- 3: claim-level confidence matches evidence quality.
- 3: conflicts, unobserved areas, access failures, and consequences are explicit.
- 2: adopted and rejected alternatives have reasons and a resolution path.

## Hard blockers

Any one means FAIL regardless of score:

- fabricated, altered, or unverified evidence presented as observed fact;
- ambiguous canonical company or mismatched regional/product identity;
- fewer than three required official contexts or two rendered/official-screenshot contexts while claiming
  acceptance readiness;
- a material high-confidence claim with missing or weak evidence, or a broken evidence reference;
- proprietary or unknown-license font selected for implementation, missing Korean support, or unverified PDF
  embedding rights;
- instruction to reuse a logo, wordmark, mascot, slogan, company photo/illustration/icon, product screenshot,
  production CSS, or substantially copied product layout;
- company-specific values written into common core, or theme switching requiring fact/content/semantic-layout
  changes;
- invalid schema, missing required theme candidate, or extraction output written outside its allowed directory;
- acceptance or reviewer evidence bound to a different artifact hash;
- wording that presents the score as statistical accuracy or approves final rendered visual quality.

## Score caps

Apply the lowest relevant cap:

- no official first-party source: maximum 89;
- no rendered/official-screenshot evidence: maximum 94;
- no claim-level evidence ledger: maximum 90;
- only one visual surface investigated: maximum 95;
- no access dates/currentness record: maximum 95;
- unresolved target identity, font rights, Korean glyph support, or PDF embedding for an adopted choice: hard
  blocker rather than a cap.

## Independent acceptance

Both reviewers must score at least 90 and meet every category floor. The lower score is final. A total-score
difference above two points or a category difference above one point requires a third adjudicator. Reviewers
never edit the artifact they score.
