#!/usr/bin/env bash
# REQUIRED first step. Creates the task store; every other command fails until this runs.
# Default location: iCloud Drive (synced across Macs), else XDG data home, or $TRACK_DIR.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"

s="$(store_dir)"
if [ -f "$s/$MARKER" ]; then
  echo "store already set up: $s"
  exit 0
fi
ensure_store || exit 1
case "$s" in
  *"com~apple~CloudDocs"*) where="iCloud Drive (synced)";;
  "${TRACK_DIR:-__none__}"*) where="\$TRACK_DIR";;
  *) where="local";;
esac
echo "store created ($where): $s"
