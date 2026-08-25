---
name: missions
description: Manage durable, Git-synced macro work in scoped .missions files. Use for MISSIONS, bare M-* references, M-* STATUS or DONE, and /missions create or delete.
---

# Missions

A mission is durable macro work that must survive threads and remain visible in Git. It is
not an ephemeral thread task and not a factual context. Store one mission in
`<scope>/.missions/<lower-kebab-name>.md`; refer to it canonically as
`M-<UPPER-KEBAB-NAME>`.

Mission files describe the current plan and work state. Keep them current by editing
existing sections. Never append a chronological activity log; Git is the history.

## Monorepo model

A scope is a directory containing `AGENTS.md` or `CLAUDE.md`.

> Read by scanning downward from the current directory. Write to the nearest scope found
> by walking upward from the subject path.

- From the repository root, reads see missions in every nested scope. From a nested scope,
  reads see only that directory and scopes below it.
- Paths and scope-qualified references are relative to the Git root. If a bare reference
  is ambiguous, use `scope-path:M-NAME`, for example `apps/web:M-RELEASE`.
- A mission name is unique within its scope.

## Commands

Helper scripts live in `scripts/` and should be run with Bash from the intended working
directory.

| User input | Behavior |
|---|---|
| `MISSIONS` | Run `scripts/list.sh` and show active missions only. |
| bare `M-*` | Resolve with `scripts/resolve.sh`, read the mission, and treat it as the current target. |
| `M-* STATUS` | Run `scripts/status.sh M-*` and report its current work sections. |
| `M-* DONE` | Read `references/completion.md`, follow its completion procedure, then run `scripts/done.sh M-*`. |
| `/missions create NAME` | Run `scripts/create.sh NAME [subject-path]`. The subject path defaults to the current directory. Then fill the mission with known facts; do not invent details. |
| `/missions delete M-*` | Ask for explicit confirmation, then run `scripts/delete.sh --yes M-*`. Never bypass confirmation. |

`scripts/list.sh --all` includes done missions and `scripts/list.sh --done` lists only done
missions. `scripts/status.sh` without a reference prints scope-wide counts and active
blocker flags. These are supporting operations, not additional user commands.

There are only two statuses: `active` and `done`. Blockers belong in `## Blocked`; they are
not a status. Do not add START, PAUSE, BLOCK, UPDATE, ARCHIVE, or CLEAN commands.

## Loading contexts

The `## Contexts` section may contain canonical `C-*` references. This relationship is
one-way: missions may reference contexts; never edit a context merely to point back to a
mission.

When loading a mission, inspect only its declared context references. If the `contexts`
skill is available, load it and resolve/read those references lazily as the work needs
them. Report each missing or ambiguous reference clearly. If the skill is unavailable,
say that context references could not be resolved; do not guess paths or create contexts.

## Working on a mission

During authorized work targeted by a mission, use thread tasks for immediate execution.
At the end of the work, update the mission once with the resulting current truth:

- Update `## Current state` and the applicable work sections.
- Move or remove items among `## In progress`, `## Blocked`, `## Next`, and
  `## Nice to have` so they do not contradict each other.
- Keep completed detail only when it helps define the outcome or done criteria. Do not
  accumulate checked-off work or session notes.
- Update `## Objective / Outcome`, `## Done when`, or `## Contexts` only when their current
  meaning changed.

## File format

Frontmatter contains `name` (lower kebab), `description`, and `status` (`active` or
`done`). Use `template.mission.md`. Keep every required section present so state is easy
to scan. Empty work sections contain `- None.`
