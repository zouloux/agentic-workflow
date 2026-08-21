#!/usr/bin/env bash
# Print the nearest scope and destination for a context concerning the given path.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

target="${1:-$PWD}"
scope="$(nearest_scope "$target")"
root="$(git_root)"
if [ "$scope" = "$root" ]; then scope_path='.'; else scope_path="${scope#"$root"/}"; fi

printf 'scope path : %s\n' "$scope_path"
printf 'scope dir  : %s\n' "$scope"
printf 'write into : %s/.contexts/\n' "$scope"
