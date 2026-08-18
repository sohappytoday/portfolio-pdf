# Company-neutral layouts

This directory is reserved for semantic HTML produced by `$build-common-portfolio-system`.

During incremental design work, this directory may contain layouts only for the current `result/content/`
inventory (for example, one cover page). Each layout owns a page directory: `NN-slug/NN-slug.html` and its
local `theme.css`. When a content page is added or removed, update
`portfolio-system/page-map.json` and this layout set together.

A full portfolio-render set contains one `NN-slug/NN-slug.html` for every intended `result/content/NN-slug.md`. Each page must:

- link a sibling `theme.css` and contain no company-specific asset or selector;
- declare `data-page-number`, `data-page-type`, and `data-density` values matching `page-map.json`;
- expose at least one exact content-source probe with `<meta name="pdf-text-probe" content="...">`;
- render the same DOM under neutral and company themes at 1280 by 720 pixels.

`theme.css` is a development-only neutral preview entry point. It imports the common core and neutral fixture
theme so a layout can be opened directly in a browser. It is not a company build artifact: final company
renders compile their own `pages/theme.css` under `result/design/<company>/builds/<build-id>/`.

Until the complete set exists, `$apply-company-art-direction` may run only in `adapter-proof` mode. Legacy
company HTML is not valid input for this directory.
