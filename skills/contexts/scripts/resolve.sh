#!/usr/bin/env bash
# Resolve C-NAME or scope-path:C-NAME downward from a directory.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

query="${1:-}"
[ -n "$query" ] || { echo 'usage: resolve.sh <C-NAME|scope-path:C-NAME> [start-dir]' >&2; exit 1; }
start="${2:-$PWD}"
[ -d "$start" ] || { printf 'not a directory: %s\n' "$start" >&2; exit 1; }
start="$(cd -- "$start" && pwd -P)"
root="$(git_root)"
matches="$(resolve_by_ref "$query" "$start")"
count="$(printf '%s' "$matches" | grep -c . || true)"

if [ "$count" -eq 0 ]; then
  echo "not found: $query" >&2
  exit 1
fi
if [ "$count" -gt 1 ]; then
  echo "ambiguous \"$query\"; use scope-path:C-NAME:" >&2
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    name="$(field "$file" name)"
    [ -n "$name" ] || name="$(basename "$file" .md)"
    printf '  %s:%s\n' "$(scope_path_of_file "$file" "$root")" "$(canonical_ref "$name")" >&2
  done <<EOF
$matches
EOF
  exit 2
fi

printf '%s\n' "$matches"
