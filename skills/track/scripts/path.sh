#!/usr/bin/env bash
# Print the absolute path of the current project's tasks.md (creating it if needed).
# Use this to open the file for manual edits (clean, delete, reorder, edit text).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
require_store || exit 1
project_file; echo
