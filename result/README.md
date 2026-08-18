# result/ — page content and generated builds

`content/` is the user-authored source of facts. `result/content/` is the company-neutral, page-level
portfolio copy. Company research and themes never silently rewrite either directory.

```text
result/
  content/
    NN-slug.md                       # one portfolio page per file; filename owns order
  layout/
    NN-slug.html                     # optional shared semantic DOM, one per content page
  design/
    <company-slug>/
      builds/<build-id>/             # immutable generated evidence
        inputs.lock.json
        preflight.json
        pages/                       # compiled theme, HTML, PNG, per-page PDFs
        fixtures/                    # neutral/company fixture proof
        reviews/
        acceptance.json
      current.json                   # optional pointer to an accepted build only
```

## Rules

- Keep `result/content/` aligned with `portfolio-system/page-map.json`; filename and page number are the
  canonical sequence.
- `result/layout/` is owned by the common-system workflow. It must remain company-neutral and map one-to-one
  to `result/content/` before a full company portfolio render is allowed.
- Application output is append-only: create a new build ID instead of editing an existing build.
- A company theme belongs in `designs/<company-slug>/application/`; research evidence belongs in
  `designs/<company-slug>/research/art-direction/`.
- Only a hash-matching accepted build may be referenced by `current.json`.
