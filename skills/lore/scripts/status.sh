#!/usr/bin/env bash
# Show lore counts and health flags at and below the current directory.
# Health: oversized (>1000 lines), stale (>90 days), broken file refs.
# A "file ref" is a backtick token starting with `./` (globs with `*` are skipped).
# Refs are resolved relative to each lore's own scope (its AGENTS.md/CLAUDE.md dir).
# Usage: status.sh [start-dir]   (default: CWD)
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

start="${1:-$PWD}"
root="$(git_root)"
MAX_LINES=1000
STALE_DAYS=90

active=0; archived=0; health=""

while IFS= read -r f; do
  [ -n "$f" ] || continue
  status="$(field "$f" status)"; [ -n "$status" ] || status="active"
  if [ "$status" = archived ]; then archived=$((archived+1)); continue; fi
  active=$((active+1))

  name="$(field "$f" name)"; [ -n "$name" ] || name="$(basename "$f" .lore.md)"
  sp="$(scope_path_of_file "$f" "$root")"
  scopedir="$(scope_dir_of_file "$f")"
  label="$sp:$name"

  lines="$(wc -l < "$f" | tr -d ' ')"
  [ "$lines" -gt "$MAX_LINES" ] && health="$health  ! big: $label ($lines lines)
"
  if [ -n "$(find "$f" -mtime +$STALE_DAYS 2>/dev/null)" ]; then
    health="$health  ! stale: $label (>$STALE_DAYS days)
"
  fi
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    [ -e "$scopedir/$ref" ] || health="$health  ! missing: $ref (in $label)
"
  done < <(grep -oE '`[^`]+`' "$f" | tr -d '`' | grep '^\./' | grep -v '\*' | sort -u || true)
done < <(find_lores "$start")

printf 'Lore under %s: %d active, %d archived (%d total)\n' \
  "$start" "$active" "$archived" "$((active+archived))"
echo
if [ -n "$health" ]; then echo "Health:"; printf '%s' "$health"; else echo "Health: all good"; fi
