#!/usr/bin/env bash
# Preflight or apply the mechanical, scope-preserving migration from lore to contexts.
set -euo pipefail

mode=check
start=''
for arg in "$@"; do
  case "$arg" in
    --check) mode=check ;;
    --apply) mode=apply ;;
    -h|--help)
      echo 'usage: migrate.sh [--check|--apply] [project-root]'
      exit 0
      ;;
    *)
      [ -z "$start" ] || { echo 'only one project root may be supplied' >&2; exit 1; }
      start="$arg"
      ;;
  esac
done
start="${start:-$PWD}"
[ -d "$start" ] || { echo "not a directory: $start" >&2; exit 1; }
start="$(cd "$start" && pwd)"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/contexts-migrate.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
lores="$tmp/lores"
markers="$tmp/markers"
collisions="$tmp/collisions"
: > "$lores"
: > "$markers"
: > "$collisions"

find "$start" \
  \( -name node_modules -o -name .git -o -name dist -o -name build \) -prune -o \
  -type d -name .lores -print 2>/dev/null | sort > "$lores"
find "$start" \
  \( -name node_modules -o -name .git -o -name dist -o -name build \) -prune -o \
  -type f \( -name AGENTS.md -o -name CLAUDE.md \) -print 2>/dev/null | sort |
  while IFS= read -r marker; do
    if grep -Eiq '(^|[^[:alnum:]_])lore([^[:alnum:]_]|$)|\.lores|skills/lore' "$marker"; then
      printf '%s\n' "$marker"
    fi
  done > "$markers"

source_index=0
while IFS= read -r source; do
  [ -n "$source" ] || continue
  while IFS= read -r candidate; do
    [ -n "$candidate" ] || continue
    case "$candidate" in
      "$source"/*) printf 'nested lore directory: %s (inside %s)\n' "$candidate" "$source" >> "$collisions" ;;
    esac
  done < "$lores"
  source_index=$((source_index + 1))
  scope="$(dirname "$source")"
  destination="$scope/.contexts"
  if [ ! -f "$scope/AGENTS.md" ] && [ ! -f "$scope/CLAUDE.md" ]; then
    printf 'unscoped lore directory: %s\n' "$source" >> "$collisions"
  fi
  if [ -e "$destination" ]; then
    printf 'destination exists: %s\n' "$destination" >> "$collisions"
  fi
  if [ ! -w "$scope" ]; then
    printf 'scope is not writable: %s\n' "$scope" >> "$collisions"
  fi

  paths="$tmp/paths.$source_index"
  : > "$paths"
  while IFS= read -r entry; do
    relative="${entry#"$source"/}"
    if [ -f "$entry" ]; then
      case "$relative" in *.lore.md) relative="${relative%.lore.md}.md" ;; esac
      if [ ! -w "$(dirname "$entry")" ]; then
        printf 'directory is not writable: %s\n' "$(dirname "$entry")" >> "$collisions"
      fi
    fi
    printf '%s\n' "$relative" >> "$paths"
  done < <(find "$source" -mindepth 1 -print 2>/dev/null)
  duplicates="$(sort "$paths" | uniq -d)"
  if [ -n "$duplicates" ]; then
    while IFS= read -r duplicate; do
      [ -n "$duplicate" ] && printf 'filename collision in %s: %s\n' "$source" "$duplicate" >> "$collisions"
    done <<EOF
$duplicates
EOF
  fi
done < "$lores"

while IFS= read -r marker; do
  [ -n "$marker" ] || continue
  if [ ! -w "$marker" ]; then
    printf 'instruction file is not writable: %s\n' "$marker" >> "$collisions"
  fi
done < "$markers"

lore_count="$(grep -c . "$lores" || true)"
marker_count="$(grep -c . "$markers" || true)"
if [ "$lore_count" -eq 0 ] && [ "$marker_count" -eq 0 ]; then
  echo "no lore upgrade needed under $start"
  exit 0
fi
if ! command -v perl >/dev/null 2>&1; then
  echo 'required command missing: perl (needed for mechanical reference updates)' >> "$collisions"
fi

printf 'Lore upgrade found under %s: %s scoped directories, %s instruction files.\n' \
  "$start" "$lore_count" "$marker_count"
if [ -s "$collisions" ]; then
  echo 'Preflight failed; nothing was changed:' >&2
  while IFS= read -r collision; do printf '  %s\n' "$collision" >&2; done < "$collisions"
  exit 2
fi

if [ "$mode" = check ]; then
  while IFS= read -r source; do [ -n "$source" ] && printf '  move %s -> %s/.contexts\n' "$source" "$(dirname "$source")"; done < "$lores"
  while IFS= read -r marker; do [ -n "$marker" ] && printf '  update %s\n' "$marker"; done < "$markers"
  echo 'No collisions detected. After explicit user confirmation, rerun with --apply.'
  exit 0
fi

while IFS= read -r source; do
  [ -n "$source" ] || continue
  destination="$(dirname "$source")/.contexts"
  mv "$source" "$destination"
  while IFS= read -r file; do
    mv "$file" "${file%.lore.md}.md"
  done < <(find "$destination" -type f -name '*.lore.md' -print 2>/dev/null)
  while IFS= read -r file; do
    perl -pi -e 's/\.lores\b/.contexts/g; s/\.lore\.md\b/.md/g' "$file"
  done < <(find "$destination" -type f -name '*.md' -print 2>/dev/null)
done < "$lores"

while IFS= read -r marker; do
  [ -n "$marker" ] || continue
  perl -pi -e 's/\.lores\b/.contexts/g; s{skills/lore\b}{skills/contexts}g; s/\bLore\b/Contexts/g; s/\blore\b/contexts/g' "$marker"
done < "$markers"

printf 'Migrated %s lore directories and updated %s instruction files.\n' "$lore_count" "$marker_count"
