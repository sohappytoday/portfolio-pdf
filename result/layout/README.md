# Company-neutral layouts

This directory is reserved for semantic HTML produced by `$build-common-portfolio-system`.

A complete set contains one `NN-slug.html` for every `result/content/NN-slug.md`. Each page must:

- link a sibling `theme.css` and contain no company-specific asset or selector;
- declare `data-page-number`, `data-page-type`, and `data-density` values matching `page-map.json`;
- expose at least one exact content-source probe with `<meta name="pdf-text-probe" content="...">`;
- render the same DOM under neutral and company themes at 1280 by 720 pixels.

Until the complete set exists, `$apply-company-art-direction` may run only in `adapter-proof` mode. Legacy
company HTML is not valid input for this directory.
