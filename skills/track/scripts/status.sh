#!/usr/bin/env bash
# Health + counts. No args → current project. --global → every project.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
require_store || exit 1

count_file() {  # prints "open done branches" for one tasks.md
  awk -F' \\| ' '
    /^- \[ \] / { open++; b[$2]=1 }
    /^- \[x\] / { done++ }
    END { nb=0; for (k in b) nb++; printf "%d %d %d\n", open+0, done+0, nb }
  ' "$1"
}

if [ "${1:-}" = "--global" ]; then
  s="$(store_dir)"
  [ -d "$s" ] || { echo "(no store yet)"; exit 0; }
  to=0; td=0
  for d in "$s"/*/; do
    [ -f "$d/tasks.md" ] || continue
    read -r o dn _ < <(count_file "$d/tasks.md")
    [ "$o" = 0 ] && [ "$dn" = 0 ] && continue
    printf '%-40s %d open, %d done\n' "$(cat "$d/origin" 2>/dev/null || basename "$d")" "$o" "$dn"
    to=$((to+o)); td=$((td+dn))
  done
  printf '%-40s %d open, %d done\n' "TOTAL" "$to" "$td"
else
  f="$(project_file)"
  read -r o dn nb < <(count_file "$f")
  printf '%s: %d open, %d done, across %d branch(es)\n' "$(basename "$(git_root)")" "$o" "$dn" "$nb"
  echo "store: $(store_dir)"
fi
