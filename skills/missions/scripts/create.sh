#!/usr/bin/env bash
# Create a mission from the template in the nearest scope.
# Usage: create.sh <NAME|M-NAME> [subject-path]
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

raw="${1:-}"
[ -n "$raw" ] || { echo 'usage: create.sh <NAME|M-NAME> [subject-path]' >&2; exit 1; }
name="$(normalize_name "$raw")" || { echo "invalid mission name: $raw" >&2; exit 1; }
subject="${2:-$PWD}"
scope="$(nearest_scope "$subject")"
directory="$scope/.missions"
file="$directory/$name.md"
[ ! -e "$file" ] || { echo "mission already exists: $file" >&2; exit 1; }

title="$(printf '%s' "$name" | tr '-' ' ' | awk '{ for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) substr($i,2); print }')"
mkdir -p "$directory"
awk -v name="$name" -v title="$title" '
  { gsub(/<lower-kebab-name>/, name); gsub(/<Mission Name>/, title) }
  /description: <one-line mission outcome>/ { print "description: Durable work for " title "."; next }
  { print }
' "$(dirname "$0")/../template.mission.md" > "$file"

printf 'created %s at %s\n' "$(canonical_ref "$name")" "$file"
