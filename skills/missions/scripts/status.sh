#!/usr/bin/env bash
# Show one mission's current work state, or scope-wide mission counts.
# Usage: status.sh [M-NAME|scope-path:M-NAME] [start-dir]
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

if [ "$#" -gt 0 ] && { [[ "$1" == M-* ]] || [[ "$1" == m-* ]] || [[ "$1" == *:M-* ]] || [[ "$1" == *:m-* ]]; }; then
  query="$1"
  start="${2:-$PWD}"
  file="$("$(dirname "$0")/resolve.sh" "$query" "$start")"
  name="$(field "$file" name)"
  status="$(field "$file" status)"; [ -n "$status" ] || status=active
  printf '%s [%s]\n\n' "$(canonical_ref "$name")" "$status"
  for heading in 'Objective / Outcome' 'Current state' 'In progress' 'Blocked' 'Next' 'Nice to have' 'Done when' 'Contexts'; do
    print_section "$file" "$heading"
    printf '\n'
  done
  exit 0
fi

start="${1:-$PWD}"
[ -d "$start" ] || { printf 'not a directory: %s\n' "$start" >&2; exit 1; }
start="$(cd -- "$start" && pwd -P)"
root="$(git_root)"
active=0
done_count=0
blocked=''
while IFS= read -r file; do
  [ -n "$file" ] || continue
  status="$(field "$file" status)"; [ -n "$status" ] || status=active
  if [ "$status" = done ]; then
    done_count=$((done_count + 1))
    continue
  fi
  active=$((active + 1))
  if section_has_work "$file" Blocked; then
    label="$(scope_path_of_file "$file" "$root"):$(canonical_ref "$(field "$file" name)")"
    blocked="${blocked}${label}\n"
  fi
done < <(find_missions "$start")

printf 'Missions under %s: %d active, %d done (%d total)\n' "$start" "$active" "$done_count" "$((active + done_count))"
if [ -n "$blocked" ]; then
  printf 'Blocked active missions:\n%b' "$blocked"
else
  printf 'Blocked active missions: none\n'
fi
