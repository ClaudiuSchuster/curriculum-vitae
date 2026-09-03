# Claudiu Schuster — CV

<p align="center">
  <a href="https://github.com/ClaudiuSchuster/curriculum-vitae/actions/workflows/cv.yml"><img src="https://github.com/ClaudiuSchuster/curriculum-vitae/actions/workflows/cv.yml/badge.svg" alt="CV build status"></a>
  <a href="https://github.com/ClaudiuSchuster/curriculum-vitae/releases/latest"><img src="https://img.shields.io/github/v/release/ClaudiuSchuster/curriculum-vitae?display_name=tag&amp;label=release" alt="Latest release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/ClaudiuSchuster/curriculum-vitae" alt="MIT License"></a>
  <a href="https://github.com/sponsors/ClaudiuSchuster"><img src="https://img.shields.io/github/sponsors/ClaudiuSchuster?label=sponsor" alt="Sponsor Claudiu Schuster"></a>
</p>

<p align="center">
  <a href="https://claudiuschuster.de/">
    <img src="dist/Claudiu_Schuster_CV_social_card.png" width="100%" alt="Claudiu Schuster — Senior Cloud and Platform Engineer — bilingual curriculum vitae">
  </a>
</p>

<p align="center">
  <a href="https://github.com/ClaudiuSchuster/curriculum-vitae/releases/latest/download/Claudiu_Schuster_CV_DE.pdf"><strong>Download · Deutsch (PDF)</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/ClaudiuSchuster/curriculum-vitae/releases/latest/download/Claudiu_Schuster_CV_EN.pdf"><strong>Download · English (PDF)</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/ClaudiuSchuster/curriculum-vitae/releases/latest">Version history</a>
</p>

Bilingual, two-page A4 curriculum vitae with a shared visual identity:

- `dist/Claudiu_Schuster_CV_DE.pdf` — German
- `dist/Claudiu_Schuster_CV_EN.pdf` — English

The repository contains the editable HTML/CSS sources, portrait, generated PDFs, review preview and all scripts needed to rebuild and validate both documents.

## Build and verify

Requirements:

- Google Chrome at `/usr/bin/google-chrome` (or set `CHROME_BIN`)
- GNU Make
- Poppler tools: `pdfinfo`, `pdftotext` and `pdffonts`
- Librsvg: `rsvg-convert`
- ImageMagick `montage` for preview contact sheets

```bash
make check
```

The build uses local Chrome. The check asserts two-page A4 output, embedded Noto Sans fonts, extractable text, required core content, absence of superseded contact data and at least 4.5 mm of clear space between every content block and the footer.

PDF metadata is normalized for reproducible rebuilds. Set `SOURCE_DATE_EPOCH` to a non-negative Unix timestamp when a different document timestamp is required. `CV_OUTPUT_DIR` can point validation builds at an isolated directory without replacing the committed release PDFs.

Before changing repository visibility, run:

```bash
make public-check
```

This additional gate rejects role-specific or recruitment-related files and references in both the current tree and the Git history reachable from the publishable branch.

Generate review contact sheets with:

```bash
make preview
```

Render the 1280×640 repository social card from its SVG source with:

```bash
make social-card
```

`make check` also verifies byte-for-byte that the committed card in `dist/` matches `assets/social-card.svg`.

## Releases and direct downloads

Published CV snapshots use calendar tags such as `v2026.09.03`. Every release contains both PDFs plus `SHA256SUMS`, while the links below always resolve to the newest release:

- [German CV — latest PDF](https://github.com/ClaudiuSchuster/curriculum-vitae/releases/latest/download/Claudiu_Schuster_CV_DE.pdf)
- [English CV — latest PDF](https://github.com/ClaudiuSchuster/curriculum-vitae/releases/latest/download/Claudiu_Schuster_CV_EN.pdf)

Prepare and verify the release payload with:

```bash
make release-assets
make public-check
```

Pushing a `vYYYY.MM.DD` tag runs the full public-readiness gate and publishes the two verified PDFs with their checksums. A single GitHub Actions workflow covers pull-request checks, CodeQL analysis, main-branch verification and tagged releases.

## Updating the CVs

1. Edit the shared CV presentation in `src/cv.css`, the relevant content file in `src/`, or the repository card in `assets/social-card.svg`.
2. Replace `assets/profile.png` only when the portrait should change.
3. Run `make check` to rebuild and validate both PDFs.
4. Run `make preview` and visually inspect the generated contact sheets in `dist/`.
5. Commit the edited sources together with the regenerated PDFs and previews.

GitHub Actions repeats the complete public-readiness check for every push and pull request.

## License

The build sources and supporting code are available under the [MIT License](LICENSE).
