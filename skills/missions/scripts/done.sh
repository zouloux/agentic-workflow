#!/usr/bin/env bash
# Mark one resolved mission done. The skill performs context transfer first.
# Usage: done.sh <M-NAME|scope-path:M-NAME> [start-dir]
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

query="${1:-}"
[ -n "$query" ] || { echo 'usage: done.sh <M-NAME|scope-path:M-NAME> [start-dir]' >&2; exit 1; }
start="${2:-$PWD}"
file="$("$(dirname "$0")/resolve.sh" "$query" "$start")"
status="$(field "$file" status)"; [ -n "$status" ] || status=active
if [ "$status" = done ]; then
  printf '%s is already done\n' "$(canonical_ref "$(field "$file" name)")"
  exit 0
fi
set_status "$file" done
printf '%s marked done\n' "$(canonical_ref "$(field "$file" name)")"
