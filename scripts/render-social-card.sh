#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_svg="$project_dir/assets/social-card.svg"
profile_png="$project_dir/assets/profile.png"
output_png="$project_dir/dist/Claudiu_Schuster_CV_social_card.png"
render_mode=${1:-render}

if [[ "$render_mode" != render && "$render_mode" != --check ]]; then
  printf 'Usage: %s [--check]\n' "${0##*/}" >&2
  exit 2
fi

if ! command -v rsvg-convert >/dev/null 2>&1; then
  printf 'rsvg-convert is required. Install librsvg2-bin.\n' >&2
  exit 1
fi

[[ -s "$source_svg" ]] || { printf 'Missing SVG source: %s\n' "$source_svg" >&2; exit 1; }
[[ -s "$profile_png" ]] || { printf 'Missing portrait asset: %s\n' "$profile_png" >&2; exit 1; }

render_dir=$(mktemp -d /tmp/cv-social-card.XXXXXX)
candidate_png="$render_dir/social-card.png"

cleanup() {
  case "$render_dir" in
    /tmp/cv-social-card.*) rm -rf -- "$render_dir" ;;
  esac
}
trap cleanup EXIT

cp "$source_svg" "$render_dir/social-card.svg"
cp "$profile_png" "$render_dir/profile.png"

rsvg-convert \
  --width 1280 \
  --height 640 \
  --format png \
  --output "$candidate_png" \
  "$render_dir/social-card.svg"

[[ -s "$candidate_png" ]] || { printf 'Social-card render failed.\n' >&2; exit 1; }

if [[ "$render_mode" == --check ]]; then
  if [[ ! -f "$output_png" ]] || ! cmp -s "$candidate_png" "$output_png"; then
    printf 'Stale social card: %s\nRun make social-card and commit the result.\n' "${output_png#"$project_dir/"}" >&2
    exit 1
  fi
  printf 'Social card is current and reproducible.\n'
  exit 0
fi

mkdir -p "$(dirname -- "$output_png")"
install -m 0644 "$candidate_png" "$output_png"
printf 'Rendered %s\n' "$output_png"
