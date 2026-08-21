#!/usr/bin/env bash
# Delete one mission only after the caller has obtained confirmation.
# Usage: delete.sh --yes <M-NAME|scope-path:M-NAME> [start-dir]
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

[ "${1:-}" = --yes ] || {
  echo 'refusing to delete without --yes after explicit user confirmation' >&2
  echo 'usage: delete.sh --yes <M-NAME|scope-path:M-NAME> [start-dir]' >&2
  exit 1
}
shift
query="${1:-}"
[ -n "$query" ] || { echo 'usage: delete.sh --yes <M-NAME|scope-path:M-NAME> [start-dir]' >&2; exit 1; }
start="${2:-$PWD}"
file="$("$(dirname "$0")/resolve.sh" "$query" "$start")"
ref="$(canonical_ref "$(field "$file" name)")"
rm -- "$file"
printf 'deleted %s (%s)\n' "$ref" "$file"
