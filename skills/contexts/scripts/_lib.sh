#!/usr/bin/env bash
# Shared helpers for context scripts. Sourced, not run directly.
#
# Model:
#   - Read  = scan DOWNWARD from the current directory (find_contexts).
#   - Write = anchor UPWARD to the nearest scope marker (nearest_scope).
# A "scope" is a directory holding an AGENTS.md/CLAUDE.md; its contexts live in
# <scope>/contexts/. A context's "scope path" is the scope dir relative to git root.

git_root() { git rev-parse --show-toplevel 2>/dev/null || pwd; }

# find_contexts [startdir] — list *.context.md at and below startdir (default CWD).
find_contexts() {
  local start="${1:-$PWD}"
  find "$start" \
    \( -name node_modules -o -name .git -o -name dist -o -name build \) -prune -o \
    -type f -name '*.context.md' -print 2>/dev/null | sort
}

# field <file> <key> — print a single-line frontmatter value, or empty.
field() {
  awk -v k="$2" '
    NR==1 && $0=="---" { f=1; next }
    f && $0=="---" { exit }
    f && index($0, k ":") == 1 { sub("^" k ":[ \t]*", ""); print; exit }
  ' "$1"
}

# scope_dir_of_file <file> — the scope dir (parent of the containing contexts/ dir).
scope_dir_of_file() { ( cd "$(dirname "$1")/.." && pwd ); }

# scope_path_of_file <file> [root] — scope dir relative to git root ("." for root).
scope_path_of_file() {
  local sd root
  sd="$(scope_dir_of_file "$1")"
  root="${2:-$(git_root)}"
  if [ "$sd" = "$root" ]; then printf '.'; else printf '%s' "${sd#"$root"/}"; fi
}

# nearest_scope <path> — walk up from <path> to the nearest dir with AGENTS.md or
# CLAUDE.md; fall back to git root. This is where a new context must be written.
nearest_scope() {
  local d="$1" root
  # Walk up to the nearest existing directory (the path may not exist yet).
  while [ -n "$d" ] && [ "$d" != "/" ] && [ ! -d "$d" ]; do d="$(dirname "$d")"; done
  [ -d "$d" ] || d="$PWD"
  d="$(cd "$d" 2>/dev/null && pwd || pwd)"
  root="$(git_root)"
  while :; do
    if [ -f "$d/AGENTS.md" ] || [ -f "$d/CLAUDE.md" ]; then printf '%s' "$d"; return; fi
    [ "$d" = "$root" ] && break
    [ "$d" = "/" ] && break
    d="$(dirname "$d")"
  done
  printf '%s' "$root"
}

# set_status <file> <status> — set/insert the frontmatter status field.
set_status() {
  awk -v s="$2" '
    NR==1 && $0=="---" { print; f=1; next }
    f && $0=="---" { if (!seen) print "status: " s; print; f=0; next }
    f && index($0,"status:")==1 { print "status: " s; seen=1; next }
    { print }
  ' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# resolve_by_name <name|scope-path:name> [start] — print matching file path(s),
# scanning downward from start (default CWD). May print 0, 1, or several lines.
resolve_by_name() {
  local q="$1" start="${2:-$PWD}" root scopefilter="" name
  root="$(git_root)"
  case "$q" in
    */*:*|*:*) scopefilter="${q%:*}"; name="${q##*:}" ;;
    *) name="$q" ;;
  esac
  name="${name%.context.md}"; name="${name%.md}"
  local f n
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    n="$(field "$f" name)"; [ -n "$n" ] || n="$(basename "$f" .context.md)"
    [ "$n" = "$name" ] || continue
    if [ -n "$scopefilter" ]; then
      [ "$(scope_path_of_file "$f" "$root")" = "$scopefilter" ] || continue
    fi
    printf '%s\n' "$f"
  done < <(find_contexts "$start")
}

# print_contexts <mode> <query> <start> — aligned "scope-path : name [— desc]".
# mode: active|all|archived ; query: name+desc substring filter or "" . Returns 1 if none.
print_contexts() {
  local mode="$1" query="$2" start="$3" root
  root="$(git_root)"
  local -a sps names descs stats
  local i=0 f name status desc sp
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="$(field "$f" name)"; [ -n "$name" ] || name="$(basename "$f" .context.md)"
    status="$(field "$f" status)"; [ -n "$status" ] || status="active"
    case "$mode" in
      active)   [ "$status" = active ]   || continue ;;
      archived) [ "$status" = archived ] || continue ;;
    esac
    desc="$(field "$f" description)"
    if [ -n "$query" ]; then
      printf '%s\n%s\n' "$name" "$desc" | grep -iqF -- "$query" || continue
    fi
    sp="$(scope_path_of_file "$f" "$root")"
    sps[$i]="$sp"; names[$i]="$name"; descs[$i]="$desc"; stats[$i]="$status"
    i=$((i+1))
  done < <(find_contexts "$start")
  [ "$i" -gt 0 ] || return 1
  local w=0 s j=0
  for s in "${sps[@]}"; do [ ${#s} -gt $w ] && w=${#s}; done
  while [ $j -lt $i ]; do
    if [ "$mode" = all ]; then
      printf '%-*s : %s [%s] — %s\n' "$w" "${sps[$j]}" "${names[$j]}" "${stats[$j]}" "${descs[$j]}"
    else
      printf '%-*s : %s — %s\n' "$w" "${sps[$j]}" "${names[$j]}" "${descs[$j]}"
    fi
    j=$((j+1))
  done
  return 0
}
