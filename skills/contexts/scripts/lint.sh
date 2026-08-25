#!/usr/bin/env bash
# Validate context metadata and reject work tracking or history sections.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

start="${1:-$PWD}"
[ -d "$start" ] || { printf 'not a directory: %s\n' "$start" >&2; exit 1; }
start="$(cd -- "$start" && pwd -P)"
count=0
errors=0
warnings=0
default_warning_lines=200
default_max_lines=300

while IFS= read -r file; do
  [ -n "$file" ] || continue
  count=$((count + 1))
  name="$(field "$file" name)"
  description="$(field "$file" description)"
  tracks="$(field "$file" tracks)"
  max_lines="$(field "$file" max_lines)"
  filename="$(basename "$file" .md)"
  line_count="$(awk 'END { print NR }' "$file")"

  if [ -z "$name" ]; then
    printf '%s: missing frontmatter name\n' "$file" >&2
    errors=$((errors + 1))
  elif [ "$name" != "$filename" ]; then
    printf '%s: frontmatter name %s does not match filename %s\n' \
      "$file" "$name" "$filename" >&2
    errors=$((errors + 1))
  fi

  if [ -z "$description" ]; then
    printf '%s: missing frontmatter description\n' "$file" >&2
    errors=$((errors + 1))
  fi

  if [ -z "$tracks" ]; then
    printf '%s: warning: missing frontmatter tracks\n' "$file" >&2
    warnings=$((warnings + 1))
  fi

  hard_limit="$default_max_lines"
  if [ -n "$max_lines" ]; then
    case "$max_lines" in
      *[!0-9]*|'')
        printf '%s: max_lines must be an integer greater than %s\n' \
          "$file" "$default_max_lines" >&2
        errors=$((errors + 1))
        ;;
      *)
        if [ "$max_lines" -le "$default_max_lines" ]; then
          printf '%s: max_lines must be greater than %s\n' \
            "$file" "$default_max_lines" >&2
          errors=$((errors + 1))
        else
          hard_limit="$max_lines"
        fi
        ;;
    esac
  fi

  if [ "$line_count" -gt "$hard_limit" ]; then
    printf '%s: %s lines exceeds hard limit %s\n' \
      "$file" "$line_count" "$hard_limit" >&2
    errors=$((errors + 1))
  elif [ "$line_count" -gt "$default_warning_lines" ]; then
    if [ -n "$max_lines" ] && [ "$hard_limit" -gt "$default_max_lines" ]; then
      printf '%s: warning: %s lines exceeds %s; approved max_lines is %s\n' \
        "$file" "$line_count" "$default_warning_lines" "$hard_limit" >&2
    else
      printf '%s: warning: %s lines exceeds recommended limit %s\n' \
        "$file" "$line_count" "$default_warning_lines" >&2
    fi
    warnings=$((warnings + 1))
  fi

  forbidden="$(grep -nEi '^##[[:space:]]+(todo|progress|in progress|blocked|next|nice to have|done|done when|history|changelog)[[:space:]]*$' "$file" || true)"
  if [ -n "$forbidden" ]; then
    while IFS= read -r match; do
      printf '%s:%s: lifecycle or history section is not allowed\n' "$file" "$match" >&2
      errors=$((errors + 1))
    done <<< "$forbidden"
  fi
done < <(find_contexts "$start")

if [ "$errors" -gt 0 ]; then
  printf 'context lint failed: %s error(s), %s warning(s), %s file(s)\n' \
    "$errors" "$warnings" "$count" >&2
  exit 1
fi

printf 'context lint passed: %s file(s), %s warning(s)\n' "$count" "$warnings"
