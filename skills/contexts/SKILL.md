---
name: contexts
description: Create, load, list, search and maintain lightweight topic "context maps" stored in .contexts/, so agents can resume work on a topic without a full briefing. Use when the user mentions a context, asks to load/save/clean/archive a context, or before broad codebase exploration that relates to a known topic.
---

# Contexts

Context maps are small reference documents that let an agent (or human) pick up work
on a topic without a full briefing. One file per topic, in `contexts/<name>.context.md`.

**A context is a map, not a manual.** It points to the relevant files and records the
non-obvious decisions — it does not duplicate what the code already says. Keeping it
small is the whole point: loading a context must cost almost nothing.

## Monorepo model (read this first)

Contexts are **scoped**. A *scope* is any directory holding an `AGENTS.md`/`CLAUDE.md`
(the *scope marker*); its contexts live in `<scope>/.contexts/`. The repo root is just one
scope among others.

```
/AGENTS.md            → scope path "."          → /.contexts            (global)
/apps/app-1/AGENTS.md → scope path "apps/app-1" → /apps/app-1/.contexts
/apps/app-2/AGENTS.md → scope path "apps/app-2" → /apps/app-2/.contexts
```

**The single rule — both for you and the user:**

> **Read = scan DOWNWARD from the current directory. Write = anchor UPWARD to the nearest scope.**

- **Reading** (`list`/`search`/`status`/`load`/`archive`/`unarchive`) scans at and below
  the CWD. From the repo root you see everything; from inside `apps/app-1` you see only
  that scope's contexts. Output always shows each context's **scope path**, so there is
  never a mixup — even when two scopes use the same name.
- **Writing** (`create`/`init`) anchors to the **nearest scope marker** walking up from
  the code the topic concerns. Global/cross-cutting topic → root. App-specific → that app.
  Don't guess the location — run `scripts/scope.sh <path>` and write into the `.contexts/`
  it reports.
- **All paths inside a context** (`Related files`, etc.) are relative to **that context's
  own scope marker** — e.g. `src/...` inside `apps/app-1`, not `apps/app-1/src/...`.
- A name is unique **within a scope**. When a bare name is ambiguous across scopes, use a
  **qualified ref** `scope-path:name` (e.g. `apps/app-1:payload-admin`).

## Operations

The user (or you) can ask for any of these. Map the request to the right operation.

| Operation | What to do |
|---|---|
| **list** | Run `scripts/list.sh`. Prints `scope-path : name — description` for active contexts at/below CWD. `--all` includes archived, `--archived` only archived. Do not read the files. |
| **search** `<query>` | Run `scripts/search.sh <query>`. Matches name + description only. Use it before `create` to avoid duplicates. |
| **load** `<name>` | Run `scripts/resolve.sh <name>` to get the path (it reports ambiguity), then read **only** that file. Then follow its `Related files` **lazily** — open them on demand, never all at once. This is the cheap path; don't broaden into the codebase unless the task needs it. |
| **create** | Run `scripts/scope.sh <path-of-the-topic>` to find the right scope. Run `search` to check no close topic exists. Then copy `template.context.md`, fill it, write into that scope's `contexts/<name>.context.md`. Keep it short. |
| **update** `<name>` | Resolve with `scripts/resolve.sh`, then surgically `Edit` only the sections that changed. Never rewrite the whole file. |
| **delete** `<name>` | Confirm with the user, then remove the file. |
| **archive** `<name>` | Compact the file first (see below), then run `scripts/archive.sh <name>` to flip `status: archived`. |
| **unarchive** `<name>` | Run `scripts/unarchive.sh <name>`. |
| **status** | Run `scripts/status.sh`. Counts + health flags (oversized, stale, broken file refs) for contexts at/below CWD. |
| **clean** `[name]` | Tidy one or all contexts: drop done tasks, dedupe/merge decisions, fix stale sections, trim. A judgement task — see "Cleaning". |
| **init** | First-time setup in a scope — see "Init". |

Helper scripts live in this skill's `scripts/` directory; run them with `bash`. Reading
scripts scan downward from the CWD; `scope.sh` resolves where to write. Accept a qualified
`scope-path:name` wherever a `<name>` is ambiguous across scopes.

## File format

Frontmatter is minimal — `name`, `description`, `status` (`active` | `archived`). No
dates (the filesystem and git already have them). Body sections are all optional except
the title. See `template.context.md` for the full skeleton. Use relative paths from the
git root (e.g. `src/path/file.ts`). A context should stay well under ~1000 lines.

## Saving: the core rule

**Information is never gated behind a question; cleanup is.**

- **Facts auto-save, without asking.** The data is what must never be lost, so persist
  it directly. The user reviews via `git diff`, not via a chat prompt.
- **Cleanup is proposed (or done on request).** It is subjective and loss-tolerant — if
  the session is killed before you propose it, nothing important is lost, because the
  facts were already saved incrementally.

### Auto-save checkpoints (no asking, batched at end of turn)

Persist only when a context for the topic already exists / is loaded, and only if the
change passes the bar: *"would a future agent resuming this topic be misled without it?"*
If no — skip.

- A task is **done** → remove it from `## Tasks` and update `## Current state`.
- A **new decision** is made → add it to `## Key decisions`.
- A decision **changed** → edit it in place.
- The **user asks to save** → save all new facts **and** clean (equivalent to `clean`).
- The **user asks to commit** → update + clean the relevant context(s) just before,
  without asking. (Do not key off agent commits — commits are usually done by the user.)

Batch within a turn: three tasks finished in one turn = one write at the end, not three.
Always `Edit` the changed sections only — never rewrite the file.

### Drift (proposed, not automatic)

When you sense a context is drifting, propose — in one terse line — to update/clean/both.
Propose only when it materially helps, never as routine. Signals:

- `## Tasks` has grown large or lists items that look already done.
- `## Current state` contradicts what was just done.
- Decisions overlap or contradict each other.
- `## Related files` points to files that moved or no longer exist.
- The file is approaching ~1000 lines.

`scripts/status.sh` surfaces several of these.

## Cleaning

`clean` reorganizes without losing facts: remove done tasks, merge/dedupe decisions,
fix sections that no longer reflect reality (edit in place — don't append notes), trim
verbosity, drop empty sections. A context should always describe the *current* state.

## Archiving

Before flipping the status, compact the file: drop everything that was done, keep only
the essentials (topic, key decisions, boundaries worth remembering). Then run
`scripts/archive.sh <name>`.

## Init

Use when a scope has no `.contexts/` yet, or proactively offer it when a topic clearly
warrants contexts (ask the user first). Init applies to one scope — by default the nearest
one (`scripts/scope.sh`); in a monorepo, init the sub-app scope when the work is app-local,
the root scope when it's global. On init:

1. Create `<scope>/.contexts/`.
2. **With the user's permission**, add this paragraph to that scope's `AGENTS.md`
   (idempotent — skip if a "Contexts" section already points to this skill):

   > ## Contexts
   > This project keeps topic context maps in `.contexts/`. Before broad exploration, use
   > the **contexts** skill to list/load any relevant context. After changing files,
   > decisions or patterns a context covers, update it via the skill.
   > If the contexts skill isn't available in your environment, ask the user to install
   > it: `npx skills add zouloux/agentic-workflow --skill contexts`.

3. **With the user's permission**, add a short section to the project `README.md` so other
   devs discover it:

   > ## Contexts
   > Topic context maps live in `.contexts/`. Manage them with your agent via the contexts
   > skill: `npx skills add zouloux/agentic-workflow --skill contexts`.
