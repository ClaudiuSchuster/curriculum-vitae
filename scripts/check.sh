#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
review_dir=$(mktemp -d /tmp/cv-check.XXXXXX)
chrome_bin=${CHROME_BIN:-/usr/bin/google-chrome}
cv_output_dir=${CV_OUTPUT_DIR:-"$project_dir/dist"}

if [[ "$cv_output_dir" != /* ]]; then
  cv_output_dir="$project_dir/$cv_output_dir"
fi

cleanup() {
  case "$review_dir" in
    /tmp/cv-check.*) rm -rf -- "$review_dir" ;;
  esac
}
trap cleanup EXIT

pdfs=(
  "$cv_output_dir/Claudiu_Schuster_CV_DE.pdf"
  "$cv_output_dir/Claudiu_Schuster_CV_EN.pdf"
)

sources=(
  "cv-de.html"
  "cv-en.html"
)

[[ -x "$chrome_bin" ]] || { printf 'Chrome executable not found: %s\n' "$chrome_bin" >&2; exit 1; }

for source in "${sources[@]}"; do
  layout_dump="$review_dir/${source%.html}-layout.html"
  "$chrome_bin" \
    --headless \
    --disable-gpu \
    --disable-dev-shm-usage \
    --no-sandbox \
    --allow-file-access-from-files \
    --virtual-time-budget=1000 \
    --user-data-dir="$review_dir/chrome-${source%.html}" \
    --dump-dom \
    "file://$project_dir/src/$source" >"$layout_dump" 2>/dev/null

  grep -q 'data-layout-audit="complete"' "$layout_dump" || {
    printf 'Layout audit did not complete: %s\n' "$source" >&2
    exit 1
  }
  if grep -q 'data-footer-safe="false"' "$layout_dump"; then
    printf 'Unsafe footer clearance: %s\n' "$source" >&2
    grep -o 'data-footer-clearance-mm="[^"]*" data-footer-safe="[^"]*"' "$layout_dump" >&2
    exit 1
  fi
done

for pdf in "${pdfs[@]}"; do
  [[ -s "$pdf" ]] || { printf 'Missing PDF: %s\n' "$pdf" >&2; exit 1; }
  pdfinfo "$pdf" | grep -Eq '^Pages:[[:space:]]+2$'
  pdfinfo "$pdf" | grep -Eq '^Page size:.*\(A4\)$'
  pdftotext "$pdf" "$review_dir/$(basename "$pdf" .pdf).txt"
  test -s "$review_dir/$(basename "$pdf" .pdf).txt"
  pdffonts "$pdf" | grep -q 'NotoSans'
done

grep -q 'Über 15 Jahre' "$review_dir/Claudiu_Schuster_CV_DE.txt"
grep -q 'Senior Cloud & Platform Engineer' "$review_dir/Claudiu_Schuster_CV_EN.txt"

if rg -n 'claudiu\.schuster@x0e\.de|160 404 8080|Am Eisweiher' "$project_dir/src" "$project_dir/dist" >/dev/null; then
  printf 'Outdated contact data found.\n' >&2
  exit 1
fi

printf 'Both CVs are two-page A4 PDFs with embedded fonts, extractable text and safe footer clearance.\n'
