#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
chrome_bin=${CHROME_BIN:-/usr/bin/google-chrome}
cv_source_date_epoch=${SOURCE_DATE_EPOCH:-1788393600}
cv_output_dir=${CV_OUTPUT_DIR:-"$project_dir/dist"}

if [[ "$cv_output_dir" != /* ]]; then
  cv_output_dir="$project_dir/$cv_output_dir"
fi

if [[ ! -x "$chrome_bin" ]]; then
  printf 'Chrome executable not found: %s\n' "$chrome_bin" >&2
  exit 1
fi

if [[ ! "$cv_source_date_epoch" =~ ^[0-9]+$ ]]; then
  printf 'SOURCE_DATE_EPOCH must be a non-negative integer: %s\n' "$cv_source_date_epoch" >&2
  exit 1
fi

cv_pdf_date=$(date -u --date="@$cv_source_date_epoch" "+D:%Y%m%d%H%M%S+00'00'")

mkdir -p "$cv_output_dir"
chrome_profile=$(mktemp -d /tmp/cv-chrome.XXXXXX)

cleanup() {
  case "$chrome_profile" in
    /tmp/cv-chrome.*) rm -rf -- "$chrome_profile" ;;
  esac
}
trap cleanup EXIT

while IFS='|' read -r source_file output_file; do
  "$chrome_bin" \
    --headless \
    --disable-gpu \
    --disable-dev-shm-usage \
    --no-sandbox \
    --no-pdf-header-footer \
    --allow-file-access-from-files \
    --user-data-dir="$chrome_profile" \
    --print-to-pdf="$cv_output_dir/$output_file" \
    "file://$project_dir/src/$source_file" >/dev/null 2>&1

  if [[ ! -s "$cv_output_dir/$output_file" ]]; then
    printf 'PDF build failed: %s\n' "$output_file" >&2
    exit 1
  fi

  LC_ALL=C sed -i -E \
    "s|D:[0-9]{14}\\+00'00'|$cv_pdf_date|g" \
    "$cv_output_dir/$output_file"

  if ! grep -a -q "/CreationDate ($cv_pdf_date)" "$cv_output_dir/$output_file"; then
    printf 'PDF metadata normalization failed: %s\n' "$output_file" >&2
    exit 1
  fi
  printf 'Built %s\n' "$cv_output_dir/$output_file"
done <<'EOF'
cv-de.html|Claudiu_Schuster_CV_DE.pdf
cv-en.html|Claudiu_Schuster_CV_EN.pdf
EOF
