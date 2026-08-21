#!/usr/bin/env bash
# List missions at and below the current directory.
# Usage: list.sh [--active|--all|--done] [start-dir]
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

mode=active
start="$PWD"
for arg in "$@"; do
  case "$arg" in
    --active|--all|--done) mode="${arg#--}" ;;
    *) start="$arg" ;;
  esac
done

[ -d "$start" ] || { printf 'not a directory: %s\n' "$start" >&2; exit 1; }
start="$(cd -- "$start" && pwd -P)"
root="$(git_root)"
count=0
while IFS= read -r file; do
  [ -n "$file" ] || continue
  name="$(field "$file" name)"; [ -n "$name" ] || name="$(basename "$file" .md)"
  status="$(field "$file" status)"; [ -n "$status" ] || status=active
  case "$mode" in
    active) [ "$status" = active ] || continue ;;
    done) [ "$status" = done ] || continue ;;
  esac
  scope="$(scope_path_of_file "$file" "$root")"
  ref="$(canonical_ref "$name")"
  description="$(field "$file" description)"
  if [ "$mode" = all ]; then
    printf '%s:%s [%s] - %s\n' "$scope" "$ref" "$status" "$description"
  else
    printf '%s:%s - %s\n' "$scope" "$ref" "$description"
  fi
  count=$((count + 1))
done < <(find_missions "$start")

[ "$count" -gt 0 ] || printf '(no %s missions under %s)\n' "$mode" "$start"
