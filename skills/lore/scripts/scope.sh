#!/usr/bin/env bash
# Decide WHERE to write a lore: print the nearest scope (dir with AGENTS.md/CLAUDE.md)
# walking up from a given location, and the .lores/ dir to write into.
# Usage: scope.sh [path]   (default: CWD) — pass the path of the code the lore concerns.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

target="${1:-$PWD}"
sd="$(nearest_scope "$target")"
root="$(git_root)"
if [ "$sd" = "$root" ]; then sp="."; else sp="${sd#"$root"/}"; fi

printf 'scope path : %s\n' "$sp"
printf 'scope dir  : %s\n' "$sd"
printf 'write into : %s/.lores/\n' "$sd"
