# Development documentation

This document is the entry point for maintaining and releasing the CV repository. The [root README](../README.md) is intentionally kept as a public-facing landing page with the current downloads and project presentation.

## Project contents

The repository contains a bilingual, two-page A4 curriculum vitae with a shared visual identity:

- [`dist/Claudiu_Schuster_CV_DE.pdf`](../dist/Claudiu_Schuster_CV_DE.pdf) — generated German CV
- [`dist/Claudiu_Schuster_CV_EN.pdf`](../dist/Claudiu_Schuster_CV_EN.pdf) — generated English CV
- [`src/cv-de.html`](../src/cv-de.html) — German content
- [`src/cv-en.html`](../src/cv-en.html) — English content
- [`src/cv.css`](../src/cv.css) — shared presentation
- [`assets/profile.png`](../assets/profile.png) — portrait
- [`assets/social-card.svg`](../assets/social-card.svg) — repository social-card source
- [`dist/Claudiu_Schuster_CV_DE_EN_preview.png`](../dist/Claudiu_Schuster_CV_DE_EN_preview.png) — review contact sheet
- [`dist/SHA256SUMS`](../dist/SHA256SUMS) — release checksums
- [`scripts/`](../scripts/) — build, validation, preview and release scripts

## Local requirements

- Google Chrome at `/usr/bin/google-chrome` or a different path supplied through `CHROME_BIN`
- GNU Make
- Poppler tools: `pdfinfo`, `pdftotext` and `pdffonts`
- Librsvg: `rsvg-convert`
- ImageMagick `montage` for preview contact sheets

## Build and verify

Build both PDFs without running the validation gates with:

```bash
make build
```

Run the complete local build and validation with:

```bash
make check
```

The check uses local Chrome and asserts two-page A4 output, embedded Noto Sans fonts, extractable text, required core content, absence of superseded contact data and at least 4.5 mm of clear space between every content block and the footer.

PDF metadata is normalized for reproducible rebuilds. Set `SOURCE_DATE_EPOCH` to a non-negative Unix timestamp when a different document timestamp is required. `CV_OUTPUT_DIR` can point validation builds at an isolated directory without replacing the committed release PDFs.

## Development workflow

1. Edit the shared CV presentation in [`src/cv.css`](../src/cv.css), the relevant content file in [`src/`](../src/), or the repository card in [`assets/social-card.svg`](../assets/social-card.svg).
2. Replace [`assets/profile.png`](../assets/profile.png) only when the portrait should change.
3. Run `make check` to rebuild and validate both PDFs.
4. Run `make preview` and visually inspect the generated contact sheet in [`dist/`](../dist/).
5. Commit the edited sources together with the regenerated PDFs and previews.

Forgejo Actions repeats the complete public-readiness check for every push and pull request.

Generate review contact sheets with:

```bash
make preview
```

Render the 1280×640 repository social card from its SVG source with:

```bash
make social-card
```

`make check` also verifies byte-for-byte that the committed card in `dist/` matches [`assets/social-card.svg`](../assets/social-card.svg).

## Public-readiness check

Before changing repository visibility, run:

```bash
make public-check
```

This additional gate rejects role-specific or recruitment-related files and references in both the current tree and the Git history reachable from the publishable branch.

## Releases and direct downloads

Published CV snapshots use calendar tags such as `v2026.09.26`. Every release contains both PDFs plus `SHA256SUMS`; the links below always resolve to the newest release:

- [German and English CVs — latest release](https://oss-oo.io/ClaudiuSchuster/curriculum-vitae/releases/latest)
- [Release history](https://oss-oo.io/ClaudiuSchuster/curriculum-vitae/releases)

Prepare and verify the release payload with:

```bash
make release-assets
make public-check
```

Pushing a `vYYYY.MM.DD` tag runs the full public-readiness gate and marks the two verified PDFs with their checksums. A single Forgejo Actions workflow (`.forgejo/workflows/build.yml`) covers pull-request checks, main-branch verification and tagged builds; releases are attached to the verified tag through the forge API.

## License

The build sources and supporting code are available under the [MIT License](../LICENSE).
