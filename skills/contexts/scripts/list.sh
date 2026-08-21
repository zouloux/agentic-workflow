#!/usr/bin/env bash
# List context metadata at and below a directory without reading document bodies.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

start="${1:-$PWD}"
[ -d "$start" ] || { printf 'not a directory: %s\n' "$start" >&2; exit 1; }
start="$(cd -- "$start" && pwd -P)"
root="$(git_root)"
count=0
while IFS= read -r file; do
  [ -n "$file" ] || continue
  name="$(field "$file" name)"
  [ -n "$name" ] || name="$(basename "$file" .md)"
  description="$(field "$file" description)"
  printf '%s : %s - %s\n' \
    "$(scope_path_of_file "$file" "$root")" "$(canonical_ref "$name")" "$description"
  count=$((count + 1))
done < <(find_contexts "$start")

[ "$count" -gt 0 ] || printf '(no contexts under %s)\n' "$start"
