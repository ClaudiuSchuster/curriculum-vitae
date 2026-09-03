#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
dist_dir="$project_dir/dist"
checksums_file="$dist_dir/SHA256SUMS"
package_mode=${1:-write}

if [[ "$package_mode" != write && "$package_mode" != --check ]]; then
  printf 'Usage: %s [--check]\n' "${0##*/}" >&2
  exit 2
fi

release_files=(
  Claudiu_Schuster_CV_DE.pdf
  Claudiu_Schuster_CV_EN.pdf
)

for release_file in "${release_files[@]}"; do
  [[ -s "$dist_dir/$release_file" ]] || {
    printf 'Missing release asset: %s\n' "$dist_dir/$release_file" >&2
    exit 1
  }
done

package_dir=$(mktemp -d /tmp/cv-release-assets.XXXXXX)
candidate_file="$package_dir/SHA256SUMS"

cleanup() {
  case "$package_dir" in
    /tmp/cv-release-assets.*) rm -rf -- "$package_dir" ;;
  esac
}
trap cleanup EXIT

(
  cd "$dist_dir"
  sha256sum "${release_files[@]}"
) >"$candidate_file"

if [[ "$package_mode" == --check ]]; then
  if [[ ! -f "$checksums_file" ]] || ! cmp -s "$candidate_file" "$checksums_file"; then
    printf 'Stale release checksums: %s\nRun make release-assets and commit the result.\n' "${checksums_file#"$project_dir/"}" >&2
    exit 1
  fi
  (
    cd "$dist_dir"
    sha256sum --check "${checksums_file##*/}"
  )
  printf 'Release assets and checksums are current.\n'
  exit 0
fi

install -m 0644 "$candidate_file" "$checksums_file"
printf 'Prepared release assets in %s\n' "$dist_dir"
