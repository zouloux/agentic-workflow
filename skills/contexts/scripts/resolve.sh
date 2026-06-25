#!/usr/bin/env bash
# Resolve a context name to a file path (for load/update), scanning downward from CWD.
# Accepts a bare name, or a qualified "scope-path:name" when ambiguous.
# Usage: resolve.sh <name|scope-path:name> [start-dir]
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

q="${1:-}"; [ -n "$q" ] || { echo "usage: resolve.sh <name|scope-path:name> [start-dir]" >&2; exit 1; }
start="${2:-$PWD}"
root="$(git_root)"

matches="$(resolve_by_name "$q" "$start")"
n="$(printf '%s' "$matches" | grep -c . || true)"

if [ "$n" -eq 0 ]; then
  echo "not found: $q" >&2; exit 1
elif [ "$n" -gt 1 ]; then
  echo "ambiguous \"$q\" — qualify with scope-path:name :" >&2
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf '  %s:%s\n' "$(scope_path_of_file "$f" "$root")" "$(field "$f" name)" >&2
  done <<EOF
$matches
EOF
  exit 2
fi

printf '%s\n' "$matches"
