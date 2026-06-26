#!/usr/bin/env bash
# Flip a lore back to status: active.
# Usage: unarchive.sh <name|scope-path:name>
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

q="${1:-}"; [ -n "$q" ] || { echo "usage: unarchive.sh <name|scope-path:name>" >&2; exit 1; }
f="$("$(dirname "$0")/resolve.sh" "$q")" || exit $?
set_status "$f" active
echo "unarchived: $(scope_path_of_file "$f"):$(field "$f" name)"
