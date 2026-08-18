# Company theme contract

A company adapter supplies semantic values; it does not copy the company's interface or assets.

The adapter is created only by the application workflow. Company extraction follows
`ART_DIRECTION_CONTRACT.md`, supplies evidence-backed candidates for these variables, and produces no CSS.
Application source and immutable build rules are defined by `APPLICATION_CONTRACT.md`.

## Required variables

Every theme defines all of the following on `:root`:

```css
--theme-bg; --theme-surface; --theme-surface-strong;
--theme-text; --theme-text-muted; --theme-line;
--theme-accent; --theme-accent-strong; --theme-accent-soft;
--theme-positive; --theme-warning; --theme-negative;
--theme-display-font; --theme-body-font; --theme-mono-font;
--theme-radius-sm; --theme-radius-md; --theme-radius-lg; --theme-radius-pill;
--theme-shadow-floating; --theme-line-width;
```

## Allowed expression

A theme may tune the required variables, display/body contrast, line/radius character, background
treatment, image crop language, and self-authored icon stroke. It may provide explicitly named modifier
classes only when the semantic component still works without them.

## Forbidden coupling

- Company names, logos, proprietary fonts, mascots, slogans, and copied production CSS in `core.css`
- Layout changes that require different facts, page count, or page ordering
- Color used as the sole carrier of meaning
- Unlicensed remote assets or font loading during final render
- Theme selectors that reach into page-specific IDs
- Generated text through CSS `content`, page-number/density selectors, remote imports, or data-URI assets

## Adaptability fixture

Before acceptance, render the same representative markup under neutral and three contrasting synthetic
themes: restrained finance, editorial, and experimental technology. The content and DOM must be identical.
The canonical markup is `fixtures/sparse.html` and `fixtures/dense.html`; only `__CORE_URI__` and
`__THEME_URI__` are replaced by the renderer. Outputs and evidence follow `SYSTEM.md`.
