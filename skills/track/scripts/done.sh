#!/usr/bin/env bash
# Toggle a task done / not-done by id, in the current project.
# Usage: done.sh <id> [<id> ...]        (marks done)
#        done.sh --undo <id> [...]      (marks not done)
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
require_store || exit 1

mark="x"
if [ "${1:-}" = "--undo" ]; then mark=" "; shift; fi
[ "$#" -ge 1 ] || { echo "usage: done.sh [--undo] <id> [<id> ...]" >&2; exit 1; }

f="$(project_file)"
for id in "$@"; do
  awk -F' \\| ' -v id="$id" -v m="$mark" '
    /^- \[.\] / {
      tid=$1; sub(/^- \[.\] /,"",tid)
      if (tid==id) { sub(/^- \[.\]/, "- [" m "]"); hit=1 }
    }
    { print }
    END { if (!hit) exit 3 }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f" \
    && printf '#%s → %s\n' "$id" "$([ "$mark" = x ] && echo done || echo open)" \
    || { rm -f "$f.tmp"; echo "#$id not found" >&2; }
done
