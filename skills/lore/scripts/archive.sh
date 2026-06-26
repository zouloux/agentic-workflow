#!/usr/bin/env bash
# Flip a lore to status: archived. Compact the file BEFORE running this.
# Usage: archive.sh <name|scope-path:name>
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

q="${1:-}"; [ -n "$q" ] || { echo "usage: archive.sh <name|scope-path:name>" >&2; exit 1; }
f="$("$(dirname "$0")/resolve.sh" "$q")" || exit $?
set_status "$f" archived
echo "archived: $(scope_path_of_file "$f"):$(field "$f" name)"
