---
name: track
description: Track TODO tasks across all your projects in a store OUTSIDE the repos, so tasks survive branch switches and never pollute the working tree. One file per project, each task tagged with the branch it belongs to. Use when the user runs /track, or asks to add/list/complete/track a task or TODO for the current or any project.
---

# Track

A personal, cross-project task list that lives **outside** your repositories. Tasks are
plain markdown you can read and edit by hand; the skill just keeps them organized and
tagged with the branch + date they were created.

**Why outside the repo:** tasks stay put when you switch branches, rebase, or stash, and
never show up in `git status`. One project has one task file, regardless of branch.

Invocation: `/track <operation> [args]` — e.g. `/track add "fix the login bug"`. The
operation and its arguments arrive as one string; route them to the operations below.
The skill may also auto-trigger when the user clearly wants to note or review a task.

## Setup is required first

**`setup` must run once before anything else.** Until the store exists, every other
operation fails with a clear message telling the user to run `/track setup` — nothing is
created implicitly. This is deliberate: the store lives in a synced/shared location, so
its creation is an explicit, one-time choice, not a side effect of a stray `add`.

## Where tasks are stored

Agent-agnostic — **not** under `~/.claude`. The store path resolves in this order:

1. `$TRACK_DIR` (explicit override)
2. **iCloud Drive** if present — `~/Library/Mobile Documents/com~apple~CloudDocs/track` —
   so tasks sync across your Macs
3. `${XDG_DATA_HOME:-~/.local/share}/track` (Linux / no iCloud)

Layout:

```
<store>/.track-store              # marker — proves the dir is ours + that setup ran
<store>/<project-slug>/tasks.md   # one file per repo
<store>/<project-slug>/origin     # the repo's absolute path (for the global view)
```

- `project-slug` = repo basename + short hash of its absolute path (from
  `git rev-parse --show-toplevel`), so two repos of the same name never collide.
- `setup` creates the store only when the target is empty or already carries
  `.track-store` — a non-empty foreign directory aborts untouched. Never `rm` or overwrite
  anything in the store path yourself.

## Task format

One task per line in `tasks.md`:

```
- [ ] 2 | @feat/login | 2026-07-20 | Wire magic-link login !urgent
```

`state | id | @branch | date | free text`. Priority, tags, refs are just conventions in
the free text (`!urgent`, `#api`, `file.ts:42`) — no rigid columns. IDs are per-project
integers, assigned automatically.

## Operations

| Operation | What to do |
|---|---|
| **setup** | Run `scripts/setup.sh`. **Required once before any other op.** Creates the store (iCloud by default), prints where. Idempotent. Seed a custom path by exporting `$TRACK_DIR` first. |
| **add** `<text>` | Run `scripts/add.sh "<text>"`. Auto-tags current branch + today's date, assigns the next id. Quote the text as one argument. |
| **list** | Run `scripts/list.sh`. All tasks in the current project, branch shown per task. Add `--open` to hide done. |
| **branch** | Run `scripts/list.sh --branch`. Only tasks on the **current** branch. |
| **all** / **global** | Run `scripts/list.sh --global`. Every task across every tracked project, grouped by repo. |
| **done** `<id…>` | Run `scripts/done.sh <id> [id…]`. Marks done. `scripts/done.sh --undo <id>` reopens. |
| **status** | Run `scripts/status.sh` (current project) or `scripts/status.sh --global` (all projects). Counts + store path. |
| **edit / clean / delete** | Run `scripts/path.sh` to get the `tasks.md` path, then `Edit` it directly — reword tasks, reorder, drop done ones. A judgement task (see below). |

Helper scripts live in this skill's `scripts/` directory; run them with `bash`. They all
operate on the **current** git repo (via `git rev-parse --show-toplevel`), so run them
from inside the project you mean.

## Behavior notes

- **Adding is silent-fast.** Just run `add.sh` and confirm in one compact line — don't
  restate the whole list afterward.
- **Reading is direct.** For `list`/`branch`/`status`, run the script and show its output.
  Don't reformat unless asked.
- **Editing/deleting needs judgement** — like a cleanup. Get the file with `path.sh`, then
  `Edit` surgically (change only the lines that matter). Confirm before deleting many
  tasks at once.
- **No native TodoWrite sync.** This store is the manual, durable list; it is independent
  of any single agent session's in-memory TODO.

## Init (offer once)

If the user tries any operation before running `setup`, the scripts already tell them to
run it — relay that. On first setup, you may point out — once, briefly — how it's stored:

> Tasks are stored in iCloud Drive by default (`~/Library/Mobile
> Documents/com~apple~CloudDocs/track`), so they sync across your Macs and are shared
> across all projects and agents, surviving branch switches. Override with `$TRACK_DIR`
> (falls back to `${XDG_DATA_HOME:-~/.local/share}/track` off macOS). If the track skill
> isn't installed in an environment, add it:
> `npx skills add zouloux/agentic-workflow --skill track`.
