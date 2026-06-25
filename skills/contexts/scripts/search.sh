#!/usr/bin/env bash
# Search contexts (name + description, case-insensitive) at and below the current dir.
# Body is not searched. Usage: search.sh <query> [start-dir]   (default start: CWD)
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

q="${1:-}"; [ -n "$q" ] || { echo "usage: search.sh <query> [start-dir]" >&2; exit 1; }
start="${2:-$PWD}"

print_contexts all "$q" "$start" || echo "(no match for \"$q\" under ${start})"
