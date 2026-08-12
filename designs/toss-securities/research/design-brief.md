# Design Brief — 토스증권 (Toss Securities)

- Domain: https://www.tossinvest.com
- Extracted: 2026-08-12
- Sources: static CSS token scan (`tokens.md`, `raw/`) + WebFetch qualitative read of the homepage
- Note: the homepage for a logged-out visitor is effectively the live product (market index/stock
  list, real-time chart, filters), not a marketing landing page — so this brief reads more like a
  **fintech product UI** language than a marketing-site language. Keep that in mind when reusing it.

## 1. Brand snapshot

Toss Securities (a Toss-family fintech brand) presents as a dense, data-driven trading product
wrapped in the broader Toss visual system: soft-blue primary accent, generous but not extreme
rounding, near-flat surfaces with hairline dividers instead of heavy shadows, and a full
light/dark adaptive color system baked into CSS custom properties (`--tw-adaptive-color-*`,
`--tw-semantic-color-*`). The overall impression is "friendly-but-serious fintech" — approachable
type and color, but the layout itself is dense and utilitarian, built for scanning numbers fast.

## 2. Color

**Primary/accent — blue**
- `#3182f6` appeared 10× in the raw hex frequency scan and independently resolves as
  `--tw-adaptive-color-blue600` in the adaptive color table. This is the strongest, best-evidenced
  brand color candidate (Toss's well-known signature blue). High confidence.
- Full adaptive blue ramp resolved from CSS (`--tw-adaptive-color-blue50…900`), single-value (not
  yet confirmed as a light/dark pair — see below):
  `50 #f2f8ff · 100 #ebf4ff · 200 #dcecfe · 300 #bfdbfd · 400 #93c0fc · 500 #4396fb · 600 #3182f6 · 700 #2272eb · 800 #1b59c5 · 900 #1c4989`

**Semantic — positive/negative (Korean market convention)**
- The token map resolves `--tw-semantic-color-txt-positive → var(--tw-adaptive-color-red700)`.
  This confirms the site follows the **Korean stock-market color convention: red = up/positive,
  not down** (opposite of US convention) — an important detail if reusing this for any
  stock/finance-flavored UI element. Medium-high confidence (directly resolved in CSS, not
  inferred).
- Red/error-adjacent hex candidates: `#f04452`, `#f04251` (both 7/4× frequency) — likely
  `red600`-ish. Full adaptive red ramp partially resolved, e.g. `red100: #ffefef` (light) /
  `#3e2429` (dark), `red200: #fee2e2` / `#52262d`, `red300: #fdcbca` / `#712630`.
- Green/teal-ish candidates (`#02a262`, `#109595`) appear 3× each — plausible secondary
  status/accent colors but not confirmed as semantic "warning/success" via a resolved token name.
  Low-medium confidence.
- Yellow/warning ramp fully resolved as an adaptive pair, e.g. `yellow100: #fff3ce` (light) /
  `#312a25` (dark), `yellow700: #fcb50c` (light) / `#c95c00` (dark). High confidence this is the
  warning/caution color family.

**Light/dark adaptive system — confirmed, not a guess**
The CSS literally defines each `--tw-adaptive-color-*` custom property **twice** with two
different hex values (light build vs. dark build), e.g.:
- `--tw-adaptive-color-grey100: #2a2b31` (dark) and `#f4f5f8` (light)
- `--tw-adaptive-color-grey900: #1c1f25` (light-mode near-black text) and `#ffffff` (dark-mode
  white text) — note the scale direction *inverts* between themes (grey50→grey900 doesn't mean
  "always darker," it means "always higher-contrast against that theme's background")
- `--tw-adaptive-color-yellow50: #fef7e4` (light) / `#242322` (dark)

This is a real, structurally-confirmed light/dark adaptive palette, not a single-mode guess — call
this out explicitly if the eventual build wants theme support.

**Neutrals / surfaces**
- `#ffffff` dominates frequency (42×) — base light surface/background.
- `#101013` (7×) resolves directly as `--tw-semantic-color-bg-surface100` in dark mode — the dark
  theme's base background. High confidence.
- `#17171C` resolves as `--tw-semantic-color-bg-surface200` (dark) — a slightly-elevated dark
  surface tone.
- Light neutrals: `#f6f7f9`, `#f9fafb`, `#f2f4f6` (3-4× each) — likely light-mode surface/hover
  tiers. `#d1d6db`, `#b0b8c1` — likely light-mode border/divider tones.

**Low-confidence / unresolved**
- `#4e5968`, `#333d4b`, `#3c3c47`, `#2c2c35`, `#202027` — mid-frequency (3-5×) dark/grey text
  tones; plausible secondary text colors but not tied to a resolved semantic token name in this
  scan. Treat as directional only.
- `#90c2ff`, `#3485fa`, `#2272eb` cluster near the blue ramp but weren't individually confirmed
  against a named token — probably blue300/700-ish intermediate states (hover/pressed), not
  independently verified.
- Several `--tw-semantic-color-bg-overlay400`-style tokens are referenced heavily in box-shadow
  and border patterns but only partially resolve (sometimes to a literal hex, sometimes to another
  variable) — treat "overlay/shadow" semantic tiers as structurally real but not pixel-confirmed.

## 3. Typography

**Font stack** (from `font-family` scan, consistent across the corpus):
```
"Toss Product Sans", "Tossface", -apple-system, BlinkMacSystemFont, "Bazier Square",
"Noto Sans KR", "Segoe UI", Apple SD Gothic Neo, Roboto, "Noto Sans KR", "Helvetica Neue",
Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"
```
- `Toss Product Sans` is a proprietary brand typeface (custom-licensed, not freely embeddable) —
  **do not attempt to source/embed it**; treat it as off-limits and fall back to a geometric,
  rounded-leaning sans (e.g. Pretendard, or a similar Korean-friendly grotesque) as the stylistic
  stand-in. `Tossface` is Toss's custom emoji font — also brand-specific, skip it.
- A separate monospace stack (`Menlo, Consolas, Monaco, Andale Mono, Ubuntu Mono, monospace`)
  appears — likely used for numeric/price display, common in trading UIs for tabular-figure
  alignment. Worth reusing the *pattern* (monospace for numbers) even without the exact stack.

**Weight rhythm**
Font-weight frequency in the corpus: `500` (180×) and `600` (169×) dominate heavily, followed by
`700` (114×) and `400` (103×). This points to a **medium/semibold-forward** rhythm — body text
sits at 500 rather than 400, with 600/700 used for emphasis/headings — consistent with a dense
data UI that wants numbers and labels to read clearly at small sizes rather than a light/thin
editorial feel. (The additional 800/900/950/300 counts are likely third-party/utility CSS noise
from the bundled framework, not primary brand rhythm — lower confidence on those.)

## 4. Shape language

Border-radius frequency, high to low:
```
8px (73×) · 12px (51×) · 6px (40×) · 10px (38×) · 50% (29×, avatars/icons) · 7px (22×)
16px (18×) · 5px (13×) · 4px (12×) · 9px (11×) · 999px (5×, pills) · 100px (3×, pills)
```
Corner philosophy in one line: **consistently soft-rounded, never sharp** — the dominant band is
6–12px for cards/inputs/buttons, with 16px for larger containers and full-pill (999px/100px/50%)
reserved for chips, avatars, and badges. No 0px-radius elements appear as a meaningful pattern
(the few 0px hits are edge-case resets, not a design choice). High confidence — this is a very
consistent, high-sample-size signal.

## 5. Elevation

Box-shadow samples skew toward **flat-with-hairline-border**, not soft drop shadows:
- Most common pattern is a 0.5–0.75px inset or outset hairline using an adaptive/semantic color
  variable, e.g. `box-shadow: 0 0 0 .75px var(--tw-adaptive-color-greyOpacity200) inset` — this is
  a **1px border simulated via box-shadow** (common technique for crisp hairlines across DPRs),
  not real elevation.
- One genuine soft-shadow pattern does appear for what's likely a raised/floating element (e.g. a
  dropdown or modal):
  `box-shadow: 0 .6px .6px -1.25px rgba(0,0,0,.12), 0 2.2px 2.2px -2.5px rgba(0,0,0,.1), 0 10px
  10px -3.75px rgba(0,0,0,.0425)` — a layered, low-opacity soft shadow (multiple offsets stacking
  for a soft diffuse effect), used sparingly.

Summary: **mostly flat surfaces delineated by hairline borders/dividers**, with soft (not hard)
multi-layer shadows reserved for genuinely floating UI (menus/modals/tooltips). No hard drop
shadows observed anywhere in the sample.

## 6. Tone / voice

From the WebFetch reading of the live homepage (which is the logged-out product view, not a
marketing page):
- **Casual-but-instructional Korean copy** — e.g. system messages like "지원하지 않는
  브라우저예요" (unsupported browser) read conversationally rather than formally worded.
- **Terse, action-oriented microcopy** over explanatory marketing prose — the page prioritizes
  functional guidance and data labels over narrative selling copy.
- **Dense, data-driven information architecture** with sparse "hero" framing — real-time market
  indices, a filterable stock/index list (필터, 거래대금 순, 거래량, 급상승 sort options), and a
  live chart dominate the layout rather than a big marketing headline.
- A visible investment disclaimer in the footer ("투자 정보는 고객의 투자 판단을 위한 단순
  참고용" — investment info is reference-only for the user's own judgment) — standard regulated
  fintech boilerplate, worth echoing the *pattern* (a visible, plain-language disclaimer) if the
  eventual portfolio includes any finance-flavored demo content, without copying the wording.

Because this reading came from the product homepage rather than a marketing/about page, it's
weighted toward **UI microcopy tone**, not top-of-funnel marketing tone — treat "casual,
terse, data-forward" as the confirmed signal, but don't assume it extends to long-form brand
storytelling (that wasn't sampled here).

## 7. Layout patterns

Observed top-to-bottom structure of the sampled homepage:
1. Browser-compatibility warning banner
2. Navigation header (logo + menu — logo itself is off-limits, see Do/Don't)
3. Search prompt/entry point
4. Promotional/campaign link (AI-related campaign banner at time of extraction)
5. Market index/list section
6. "Key schedule" section (likely earnings/event calendar)
7. Real-time chart section with sort/filter controls (거래대금 순 = by trading value, 거래량 =
   by volume, 급상승 = top gainers)
8. Footer with legal links, disclaimer, and company info

Repeating rhythm: **list/table rows with a filter/sort control above them**, appearing more than
once (index list, chart section) — a strong candidate for a reusable "data list with filter chips"
pattern if the eventual build wants a data-forward section. No large single-hero marketing block
was found on this page — if the target audience expects a more marketing-forward feel, that would
need to be composed rather than copied from this particular page.

## 8. Do / Don't

**Do reuse (style language)**
- The signature blue (`#3182f6` / adaptive blue600) as primary accent.
- Korean stock-market color convention (red = positive/up) if building anything with
  gain/loss indicators.
- Soft 6–12px corner rounding on cards/buttons/inputs, pill shapes for chips/badges/avatars.
- Flat surfaces + hairline dividers as the default; soft multi-layer shadows only for
  floating/overlay elements.
- Medium/semibold-forward type weight rhythm (500/600 base, not 400) for a dense, legible feel.
- A monospace or tabular-figure treatment for numeric data.
- Full light/dark adaptive theming as a structural approach (the site clearly ships both).
- Terse, casual-but-competent Korean (or English-equivalent) microcopy tone; dense
  data-forward layout with filter/sort affordances above lists.
- The general "plain-language disclaimer" pattern for any finance-flavored demo content
  (reworded, not copied).

**Don't (off-limits brand assets)**
- Toss logo / wordmark, the Toss Securities favicon set, and the `og:image` illustration
  (`toss-securities-OG-2.png`) — never reproduce or reference these directly.
- `Toss Product Sans` and `Tossface` — proprietary licensed fonts; do not attempt to source or
  embed them. Use a stylistically similar fallback instead.
- Any Toss-specific mascot, illustration style, or slogan — none were extracted here as
  reusable, but if later research surfaces one, treat it as off-limits, not inspiration.
- Exact hex values should be treated as "inspired by," not a promise of pixel-identical brand
  color — especially the mid-confidence neutrals listed above.

## 9. Confidence & limitations

- **No rendered/visual verification was possible in this environment** — no headless
  browser or screenshot capability. Everything here comes from static CSS text extraction plus
  a markdown-converted WebFetch read of the live homepage, not an actual rendered view. If the
  user supplies a screenshot, it can be used to correct or sharpen this brief directly.
- **Strongly supported (high confidence, multi-occurrence + directly resolved in named
  tokens):** primary blue `#3182f6`; the full light/dark adaptive grey/blue/yellow/red ramps;
  border-radius distribution (6–12px core, pill for chips); flat-surface/hairline elevation
  style; medium/semibold type-weight rhythm; red-as-positive semantic convention.
- **Medium confidence (plausible, partly resolved or lower sample count):** green/teal
  candidates as a possible tertiary status color; exact mid-grey text tones (`#4e5968` etc.);
  which specific blue-ramp step maps to hover/pressed states.
- **Low confidence / single-occurrence or structural-only:** several `--tw-semantic-color-*`
  overlay/shadow tokens that reference other variables without a fully resolved literal hex in
  this static scan — noted as "referenced but unresolved" rather than invented.
- **Scope caveat:** the sampled homepage is the logged-out product view (market data/charts),
  not a marketing/about page — tone and layout findings are weighted toward UI/product feel,
  not top-of-funnel brand storytelling. A second pass against a Toss marketing/campaign page
  (if one exists) would sharpen the "hero/marketing" side of this brief, but was out of scope
  for this first pass per the agent's own guidance that the homepage alone is usually enough.
