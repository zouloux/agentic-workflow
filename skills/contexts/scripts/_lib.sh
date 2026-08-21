#!/usr/bin/env bash
# Shared helpers for context scripts. Sourced, not run directly.

git_root() { git rev-parse --show-toplevel 2>/dev/null || pwd; }

find_contexts() {
  local start="${1:-$PWD}"
  local directory file scope root
  [ -d "$start" ] || { printf 'not a directory: %s\n' "$start" >&2; return 1; }
  start="$(cd -- "$start" && pwd -P)"
  root="$(git_root)"
  while IFS= read -r directory; do
    scope="$(dirname "$directory")"
    if [ "$scope" != "$root" ] && [ ! -f "$scope/AGENTS.md" ] && [ ! -f "$scope/CLAUDE.md" ]; then
      continue
    fi
    for file in "$directory"/*.md; do
      [ -f "$file" ] && printf '%s\n' "$file"
    done
  done < <(find "$start" \
    \( -name node_modules -o -name .git -o -name dist -o -name build \) -prune -o \
    -type d -name .contexts -print 2>/dev/null | sort) | sort
}

field() {
  awk -v k="$2" '
    NR==1 && $0=="---" { f=1; next }
    f && $0=="---" { exit }
    f && index($0, k ":") == 1 { sub("^" k ":[ \t]*", ""); print; exit }
  ' "$1"
}

scope_dir_of_file() { (cd "$(dirname "$1")/.." && pwd -P); }

scope_path_of_file() {
  local scope root
  scope="$(scope_dir_of_file "$1")"
  root="${2:-$(git_root)}"
  if [ "$scope" = "$root" ]; then printf '.'; else printf '%s' "${scope#"$root"/}"; fi
}

nearest_scope() {
  local dir="$1" root
  while [ -n "$dir" ] && [ "$dir" != / ] && [ ! -d "$dir" ]; do dir="$(dirname "$dir")"; done
  [ -d "$dir" ] || dir="$PWD"
  dir="$(cd "$dir" 2>/dev/null && pwd -P || pwd -P)"
  root="$(git_root)"
  while :; do
    if [ -f "$dir/AGENTS.md" ] || [ -f "$dir/CLAUDE.md" ]; then printf '%s' "$dir"; return; fi
    [ "$dir" = "$root" ] && break
    [ "$dir" = / ] && break
    dir="$(dirname "$dir")"
  done
  printf '%s' "$root"
}

normalize_name() {
  local ref="${1##*:}"
  case "$ref" in C-*) ref="${ref#C-}" ;; c-*) ref="${ref#c-}" ;; esac
  printf '%s' "$ref" | tr '[:upper:]' '[:lower:]'
}

canonical_ref() {
  printf 'C-%s' "$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')"
}

valid_name() {
  case "$1" in
    ''|-*|*-|*[!a-z0-9-]*|*--*) return 1 ;;
    *) return 0 ;;
  esac
}

resolve_by_ref() {
  local query="$1" start="${2:-$PWD}" root scope_filter='' name file found
  root="$(git_root)"
  case "$query" in *:*) scope_filter="${query%:*}" ;; esac
  name="$(normalize_name "$query")"
  valid_name "$name" || return 0
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    found="$(field "$file" name)"
    [ -n "$found" ] || found="$(basename "$file" .md)"
    [ "$found" = "$name" ] || continue
    if [ -n "$scope_filter" ]; then
      [ "$(scope_path_of_file "$file" "$root")" = "$scope_filter" ] || continue
    fi
    printf '%s\n' "$file"
  done < <(find_contexts "$start")
}
