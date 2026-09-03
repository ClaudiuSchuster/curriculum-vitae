#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
review_dir=$(mktemp -d /tmp/cv-public-check.XXXXXX)

cleanup() {
  case "$review_dir" in
    /tmp/cv-public-check.*) rm -rf -- "$review_dir" ;;
  esac
}
trap cleanup EXIT

for forbidden_path in \
  "$project_dir"/Recruiter_* \
  "$project_dir"/src/*sre* \
  "$project_dir"/src/*cybersecurity* \
  "$project_dir"/dist/*SRE* \
  "$project_dir"/dist/*Cybersecurity*; do
  if [[ -e "$forbidden_path" ]]; then
    printf 'Private or role-specific file remains: %s\n' "$forbidden_path" >&2
    exit 1
  fi
done

private_pattern='Sandeep|Cerebra|Capgemini|recruiter conversation|job description|Stellenausschreibung|role-specific SRE|SRE v2'

if rg -I -n -i "$private_pattern" \
  --glob '!check-public.sh' \
  "$project_dir/README.md" "$project_dir/Makefile" \
  "$project_dir/.github" "$project_dir/src" "$project_dir/scripts" >/dev/null; then
  printf 'Private recruitment reference remains in the public source tree.\n' >&2
  exit 1
fi

for pdf in "$project_dir"/dist/*.pdf; do
  text_file="$review_dir/$(basename "$pdf" .pdf).txt"
  pdftotext "$pdf" "$text_file"
  if rg -n -i "$private_pattern" "$text_file" >/dev/null; then
    printf 'Private recruitment reference remains in PDF: %s\n' "$pdf" >&2
    exit 1
  fi
done

history_paths=$(git -C "$project_dir" log HEAD --name-only --format= | \
  rg -i '(^|/)(Recruiter_|.*SRE.*|.*Cybersecurity.*)' || true)
if [[ -n "$history_paths" ]]; then
  printf 'Private or role-specific files remain in Git history:\n%s\n' "$history_paths" >&2
  exit 1
fi

while IFS= read -r commit; do
  if git -C "$project_dir" grep -I -q -i -E "$private_pattern" "$commit" -- \
    '*.md' '*.html' '*.css' '*.js' '*.sh' '*.yml' '*.yaml' 'Makefile' \
    ':(exclude)scripts/check-public.sh'; then
    printf 'Private recruitment reference remains in Git commit: %s\n' "$commit" >&2
    exit 1
  fi
done < <(git -C "$project_dir" rev-list HEAD)

printf 'Public-readiness check passed: current tree and publishable Git history contain only the bilingual CV package.\n'
