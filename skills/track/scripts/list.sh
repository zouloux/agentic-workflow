#!/usr/bin/env bash
# List tasks.
#   list.sh              → all tasks in the current project (branch shown per task)
#   list.sh --branch     → only tasks on the current branch
#   list.sh --global     → all tasks across every tracked project
# Add --open to hide done tasks.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
require_store || exit 1

scope="project"; only_open=0
for a in "$@"; do
  case "$a" in
    --branch) scope="branch" ;;
    --global) scope="global" ;;
    --open)   only_open=1 ;;
    *) echo "unknown arg: $a" >&2; exit 1 ;;
  esac
done

filter_open() { if [ "$only_open" = 1 ]; then grep -v '^\[x\]' || true; else cat; fi; }

case "$scope" in
  branch)
    f="$(project_file)"
    print_tasks "$f" "$(current_branch)" | filter_open || echo "(no tasks on $(current_branch))"
    ;;
  project)
    f="$(project_file)"
    print_tasks "$f" | filter_open || echo "(no tasks in $(basename "$(git_root)"))"
    ;;
  global)
    s="$(store_dir)"
    [ -d "$s" ] || { echo "(no store yet — add a task first)"; exit 0; }
    found=0
    for d in "$s"/*/; do
      [ -f "$d/tasks.md" ] || continue
      origin="$(cat "$d/origin" 2>/dev/null || basename "$d")"
      out="$(print_tasks "$d/tasks.md" | filter_open || true)"
      [ -n "$out" ] || continue
      printf '\n%s\n' "$origin"
      printf '%s\n' "$out"
      found=1
    done
    [ "$found" = 1 ] || echo "(no tasks in any project)"
    ;;
esac
