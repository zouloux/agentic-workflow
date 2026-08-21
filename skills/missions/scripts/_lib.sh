#!/usr/bin/env bash
# Shared mission helpers. Sourced by the command scripts.

git_root() { git rev-parse --show-toplevel 2>/dev/null || pwd; }

find_missions() {
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
    -type d -name .missions -print 2>/dev/null | sort) | sort
}

field() {
  awk -v k="$2" '
    NR == 1 && $0 == "---" { frontmatter=1; next }
    frontmatter && $0 == "---" { exit }
    frontmatter && index($0, k ":") == 1 {
      sub("^" k ":[ \t]*", ""); print; exit
    }
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
  local name="$1"
  name="${name##*:}"
  name="${name%.md}"
  case "$name" in M-*|m-*) name="${name#??}" ;; esac
  name="$(printf '%s' "$name" | tr '[:upper:]_' '[:lower:]-')"
  case "$name" in
    ''|*[!a-z0-9-]*|-*|*--*|*-) return 1 ;;
  esac
  printf '%s' "$name"
}

canonical_ref() {
  local name
  name="$(normalize_name "$1")" || return 1
  printf 'M-%s' "$(printf '%s' "$name" | tr '[:lower:]' '[:upper:]')"
}

resolve_by_ref() {
  local query="$1" start="${2:-$PWD}" root scope_filter='' raw name file file_name
  root="$(git_root)"
  case "$query" in
    *:*) scope_filter="${query%:*}"; raw="${query##*:}" ;;
    *) raw="$query" ;;
  esac
  name="$(normalize_name "$raw")" || return 1
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    file_name="$(field "$file" name)"
    [ -n "$file_name" ] || file_name="$(basename "$file" .md)"
    [ "$file_name" = "$name" ] || continue
    if [ -n "$scope_filter" ]; then
      [ "$(scope_path_of_file "$file" "$root")" = "$scope_filter" ] || continue
    fi
    printf '%s\n' "$file"
  done < <(find_missions "$start")
}

set_status() {
  local file="$1" status="$2" temp
  temp="$(mktemp "${file}.tmp.XXXXXX")"
  if awk -v status="$status" '
    NR == 1 && $0 == "---" { print; frontmatter=1; next }
    frontmatter && $0 == "---" {
      if (!seen) print "status: " status
      print; frontmatter=0; next
    }
    frontmatter && index($0, "status:") == 1 {
      print "status: " status; seen=1; next
    }
    { print }
  ' "$file" > "$temp"; then
    mv "$temp" "$file"
  else
    rm -f "$temp"
    return 1
  fi
}

print_section() {
  local file="$1" heading="$2"
  awk -v heading="## $heading" '
    $0 == heading { print; in_section=1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' "$file"
}

section_has_work() {
  local file="$1" heading="$2"
  print_section "$file" "$heading" | awk '
    NR == 1 || /^[[:space:]]*$/ || /^-[[:space:]]+None\.[[:space:]]*$/ { next }
    { found=1 }
    END { exit(found ? 0 : 1) }
  '
}
