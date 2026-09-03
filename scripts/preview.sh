#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
preview_dir=$(mktemp -d /tmp/cv-preview.XXXXXX)

cleanup() {
  case "$preview_dir" in
    /tmp/cv-preview.*) rm -rf -- "$preview_dir" ;;
  esac
}
trap cleanup EXIT

pdftoppm -png -r 105 "$project_dir/dist/Claudiu_Schuster_CV_DE.pdf" "$preview_dir/de" >/dev/null 2>&1
pdftoppm -png -r 105 "$project_dir/dist/Claudiu_Schuster_CV_EN.pdf" "$preview_dir/en" >/dev/null 2>&1

montage \
  "$preview_dir/de-1.png" "$preview_dir/de-2.png" \
  "$preview_dir/en-1.png" "$preview_dir/en-2.png" \
  -tile 2x2 -geometry 620x877+12+12 -background '#c9c7c3' \
  "$project_dir/dist/Claudiu_Schuster_CV_DE_EN_preview.png"

printf 'Built CV previews in %s\n' "$project_dir/dist"
