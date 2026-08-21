#!/usr/bin/env bash
# Resolve M-NAME or scope-path:M-NAME by scanning downward from CWD.
# Usage: resolve.sh <ref> [start-dir]
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

query="${1:-}"
[ -n "$query" ] || { echo 'usage: resolve.sh <M-NAME|scope-path:M-NAME> [start-dir]' >&2; exit 1; }
start="${2:-$PWD}"
[ -d "$start" ] || { printf 'not a directory: %s\n' "$start" >&2; exit 1; }
start="$(cd -- "$start" && pwd -P)"
name="$(normalize_name "$query")" || { echo "invalid mission reference: $query" >&2; exit 1; }
matches="$(resolve_by_ref "$query" "$start")"
count="$(printf '%s' "$matches" | grep -c . || true)"

if [ "$count" -eq 0 ]; then
  echo "not found: $(canonical_ref "$name")" >&2
  exit 1
fi
if [ "$count" -gt 1 ]; then
  echo "ambiguous '$query'; qualify with scope-path:M-NAME:" >&2
  root="$(git_root)"
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    printf '  %s:%s\n' "$(scope_path_of_file "$file" "$root")" "$(canonical_ref "$(field "$file" name)")" >&2
  done <<EOF
$matches
EOF
  exit 2
fi

printf '%s\n' "$matches"
