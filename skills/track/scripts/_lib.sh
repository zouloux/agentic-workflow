#!/usr/bin/env bash
# Shared helpers for track scripts. Sourced, not run directly.
#
# Model:
#   - Tasks live OUTSIDE the repo, in a global store, so they survive branch
#     switches and never pollute the working tree.
#   - One file per project: <store>/<slug>/tasks.md. Each task carries its branch.
#   - Store path is agent-agnostic: $TRACK_DIR, else XDG data home, else ~/.local/share.

# --- store resolution -------------------------------------------------------

MARKER=".track-store"

# store_dir — where tasks live. Order:
#   1. $TRACK_DIR (explicit override)
#   2. iCloud Drive, if present on this machine → synced across Macs
#   3. XDG data home fallback (Linux / no iCloud)
store_dir() {
  if [ -n "${TRACK_DIR:-}" ]; then
    printf '%s' "$TRACK_DIR"; return
  fi
  local icloud="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  if [ -d "$icloud" ]; then
    printf '%s/track' "$icloud"; return
  fi
  printf '%s/track' "${XDG_DATA_HOME:-$HOME/.local/share}"
}

# ensure_store — create the store, safely. Called ONLY by `setup`. A dir is ours only
# if it is empty or already carries the marker; anything else aborts untouched.
ensure_store() {
  local s; s="$(store_dir)"
  if [ -e "$s" ]; then
    if [ ! -d "$s" ]; then echo "track: store path '$s' exists and is not a directory." >&2; return 1; fi
    if [ -f "$s/$MARKER" ]; then return 0; fi
    if [ -n "$(ls -A "$s" 2>/dev/null)" ]; then
      echo "track: '$s' exists, is not empty, and is not a track store." >&2
      echo "       Refusing to touch it. Set TRACK_DIR to another path, or clear it." >&2
      return 1
    fi
  fi
  mkdir -p "$s" || return 1
  printf 'track store. Managed by the track skill. Safe to delete to reset.\n' > "$s/$MARKER"
  return 0
}

# require_store — every operation EXCEPT setup calls this. Never creates anything.
# Fails with a clear, actionable message if setup was never run.
require_store() {
  local s; s="$(store_dir)"
  if [ ! -f "$s/$MARKER" ]; then
    echo "track: no store at '$s'." >&2
    echo "       Run 'setup' first:  bash \"\$(dirname \"\$0\")/setup.sh\"  (or /track setup)" >&2
    return 1
  fi
  return 0
}

# --- project resolution -----------------------------------------------------

git_root() { git rev-parse --show-toplevel 2>/dev/null || pwd; }

current_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(no-git)"; }

# project_slug [root] — stable, readable, collision-safe id for a repo.
project_slug() {
  local root; root="${1:-$(git_root)}"
  local base hash
  base="$(basename "$root")"
  hash="$(printf '%s' "$root" | shasum 2>/dev/null | cut -c1-6)"
  [ -n "$hash" ] || hash="$(printf '%s' "$root" | cksum | cut -d' ' -f1)"
  printf '%s-%s' "$base" "$hash"
}

# project_dir — <store>/<slug>. Requires an existing store (setup must have run);
# creates only the per-project subdir, never the store itself.
project_dir() {
  require_store || return 1
  local root; root="$(git_root)"
  local d; d="$(store_dir)/$(project_slug "$root")"
  if [ ! -d "$d" ]; then
    mkdir -p "$d"
    printf '%s\n' "$root" > "$d/origin"
  fi
  printf '%s' "$d"
}

# project_file — the tasks.md for the current repo, created with a header on demand.
project_file() {
  local d f; d="$(project_dir)"; f="$d/tasks.md"
  if [ ! -f "$f" ]; then
    { printf '# Tasks — %s\n' "$(basename "$(git_root)")"
      printf '%s\n\n' "$(git_root)"; } > "$f"
  fi
  printf '%s' "$f"
}

# --- task line format -------------------------------------------------------
# - [ ] {id} | @{branch} | {date} | {text}

# next_id <file> — max numeric id in file + 1 (starts at 1).
next_id() {
  awk -F' \\| ' '
    /^- \[.\] / { id=$1; sub(/^- \[.\] /,"",id); if (id+0>m) m=id+0 }
    END { print m+1 }
  ' "$1"
}

# print_tasks <file> [branch] — pretty, aligned. If <branch> given, filter to it.
# Returns 1 if nothing printed.
print_tasks() {
  local f="$1" bfilter="${2:-}"
  [ -f "$f" ] || return 1
  awk -F' \\| ' -v bf="$bfilter" '
    /^- \[.\] / {
      state=substr($0,4,1)
      id=$1; sub(/^- \[.\] /,"",id)
      br=$2; date=$3; txt=$4
      if (bf!="" && br!="@" bf) next
      printf "%s %-3s %-14s %s  (%s)\n", (state=="x"?"[x]":"[ ]"), id, br, txt, date
      n++
    }
    END { exit (n>0?0:1) }
  ' "$f"
}
