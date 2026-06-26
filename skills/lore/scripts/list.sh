#!/usr/bin/env bash
# List lore at and below the current directory, as "scope-path : name — description".
# From repo root you see everything; from inside a sub-app you see only that scope.
# Usage: list.sh [--active|--all|--archived] [start-dir]   (defaults: --active, CWD)
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

mode="active"; start=""
for a in "$@"; do
  case "$a" in
    --active|--all|--archived) mode="${a#--}" ;;
    *) start="$a" ;;
  esac
done
[ -n "$start" ] || start="$PWD"

print_lores "$mode" "" "$start" || echo "(no $mode lore under ${start})"
