# Research protocol

## Source hierarchy

Use first-party sources whenever possible:

1. official company, brand, or product page;
2. official careers, design, newsroom, press kit, or brand guide;
3. official app-store listing or official public product screenshots;
4. authoritative secondary material only to fill a declared gap.

For every source record its role, URL, access date, access state, observation method, and whether it is
official. Search results, social reposts, design galleries, and fan recreations are discovery leads, not
primary visual evidence.

Assign each distinct source surface a stable `SNN` source ID. Multiple observations from the same page or
official screenshot set reuse that source ID. Use `ENN` for atomic evidence observations. Acceptance counts
distinct source IDs, so relabeling one page cannot inflate context coverage.

## Coverage matrix

Acceptance requires at least three distinct official visual contexts, including:

- company/brand or corporate identity;
- actual product/service or official product imagery;
- one relevant additional surface such as careers, design, newsroom, app store, or a stable regional site.

At least two contexts must be inspected as rendered pages or official screenshots. Count contexts, not URLs:
several routes using the same shell and campaign count as one context unless their visual roles differ.

## Evidence quality

- `high`: repeated across official contexts and supported by rendered evidence, or explicitly documented by
  an official brand/licensing source.
- `medium`: one unambiguous rendered observation or repeated structural evidence.
- `low`: a single occurrence, code-frequency signal, inaccessible render inference, or secondary-source clue.

Never upgrade confidence merely because a conclusion feels plausible. A low-confidence item cannot be the
sole support for a theme candidate. Every evidence ID uses `E` plus at least two digits and remains stable
within a snapshot.

## Observation method

- `rendered`: directly inspected official rendered page.
- `official-screenshot`: screenshot published by the company or an official store.
- `dom`, `css`, `metadata`: structural candidate signal; not proof of actual visual dominance by itself.
- `document`: official written brand, type, or license documentation.

Write short paraphrased observations. Do not copy long CSS, markup, brand copy, or production layouts.

## Conflicts and source weighting

Classify each page as corporate, product, careers, design, newsroom, regional, or campaign. Separate stable
patterns from temporary campaign treatments. Weight evidence by relevance to the target role and audience,
then write down why a surface was adopted, down-weighted, or excluded. Do not average conflicting colors,
radii, or density into a fictional brand middle.

## Typography and restricted assets

Record observed family names only for research. Before selecting an alternative, verify:

- named license and a durable license URL or local license evidence;
- commercial portfolio and PDF embedding permission;
- Korean glyph coverage and mixed Korean/Latin/numeric behavior;
- required static weights without relying on network loading during final render.

Logos, wordmarks, mascots, slogans, proprietary illustration systems, photos, screenshots, icon packs,
production CSS, and proprietary fonts remain research-only or forbidden. The brief must work without them.

## Scenario behavior

### Company name only

Resolve the official entity and domain. Use company-wide scope when the role is absent. If parent, subsidiary,
or product ambiguity materially changes the output, list the candidates and ask one focused question.

### Multiple official visual languages

Build a source-role matrix. Identify common and conflicting signals, campaign temporariness, regional
differences, target-role relevance, and the reason for excluded directions.

### Login-only product UI

Never request or automate credentials. Use public official screenshots or de-identified user-provided images
with permission. Otherwise keep product-UI conclusions provisional and distinct from marketing conclusions.

### Proprietary font or iconic assets

Record their existence and abstract characteristics, then register them in `offLimits`. Use only verified
alternatives and self-authored portfolio expression.

### Rendering unavailable

Separate network failure, access restriction, and renderer absence. CSS and DOM values remain hypotheses.
List the minimum screenshots required to raise confidence and do not generate acceptance.

## Human-readable output structure

Keep `sources.md` auditable with these sections:

1. target scope: entity, canonical domain, region, role, date;
2. source-role matrix: one row per `SNN`, with URL, role, official status, access state, method, and date;
3. evidence ledger: one row per `ENN`, with source ID, observation, separate inference, confidence, and any
   local research-only artifact;
4. conflicts and weighting: adopted, down-weighted, and excluded surfaces with reasons;
5. font and restricted-asset evidence;
6. access failures, unobserved areas, and minimum evidence needed to resolve them.

Keep `art-direction.md` decision-oriented with these sections:

1. creative thesis and target-reader fit;
2. three to five observation -> principle -> portfolio-decision chains;
3. color, type, shape, surface, layout, imagery, icon, data, and tone directions;
4. page-type directions for cover, architecture, result, and closing;
5. use, avoid, off-limits assets, and transformation distance from the company UI;
6. uncertainties, rejected alternatives, readiness status, and future apply instructions.

The Markdown files summarize the same snapshot as `art-direction.json`; they must not introduce uncited
claims or stronger confidence.
