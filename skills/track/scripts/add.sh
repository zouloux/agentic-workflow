#!/usr/bin/env bash
# Add a task to the current project, tagged with the current branch + today's date.
# Usage: add.sh "task text"
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

[ "$#" -ge 1 ] && [ -n "$1" ] || { echo "usage: add.sh \"task text\"" >&2; exit 1; }
require_store || exit 1

f="$(project_file)"
id="$(next_id "$f")"
branch="$(current_branch)"
date="$(date +%Y-%m-%d)"
text="$*"

printf -- '- [ ] %s | @%s | %s | %s\n' "$id" "$branch" "$date" "$text" >> "$f"
printf 'added #%s @%s: %s\n' "$id" "$branch" "$text"
