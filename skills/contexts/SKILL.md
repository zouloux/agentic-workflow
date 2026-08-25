---
name: contexts
description: >
  Create, load, update, delete, and migrate durable factual context maps stored in scoped
  .contexts directories. Use when the user mentions contexts, references C-<NAME>, asks to
  preserve system knowledge, or when a project still uses the deprecated lore format.
---

# Contexts

Contexts are small, durable knowledge maps for systems and subjects. Each context lives at
`<scope>/.contexts/<name>.md` and has the canonical reference `C-<UPPER-KEBAB-NAME>`.
For example, `.contexts/deploy-routing.md` is `C-DEPLOY-ROUTING`.

A context records only current knowledge within its declared frontmatter `tracks`:

- design choices and their durable reasons;
- known problems and non-obvious gotchas that remain true;
- rules, invariants, and boundaries;
- authoritative files and documentation.

Contexts are never work tracking. Do not store TODOs, progress, in-progress or blocked
states, next actions, nice-to-have items, plans, or any other work lifecycle information.
If such information appears during an update, leave it out rather than translating it.
Git is the history: never store chronology, completed work, migration journals, changelogs,
or superseded facts. Do not restate implementation details that are obvious from source.

Invocation: `/contexts <operation> [args]`. A bare canonical reference such as
`C-DEPLOY-ROUTING` means: resolve and silently load that context, then use it as the factual
scope for the accompanying request. Multiple bare references load each named context. A
message containing only references loads them and replies with one compact acknowledgement.
Never treat a bare `C-*` reference as a request to create or update a context.

## Scopes

A scope is a directory containing `AGENTS.md` or `CLAUDE.md`. Its contexts live in that
directory's `.contexts/` directory. The repository root is one scope among potentially many.

> Read downward from the current directory. Write upward to the nearest scope.

- `list` and `load` scan `.contexts/` directories at and below the current working directory.
- `create` anchors upward from the subject path to the nearest scope marker. Use
  `scripts/scope.sh <subject-path>`; do not guess.
- `update` and `delete` target an existing context found by downward resolution.
- Paths written inside a context are relative to that context's scope marker.
- A name is unique within a scope. If a reference is ambiguous, qualify it as
  `scope-path:C-NAME`, for example `apps/admin:C-DEPLOY-ROUTING`. Use
  `.:C-NAME` for the root scope.

## Operations

| Operation | Action |
|---|---|
| **list** | Run `scripts/list.sh [start-dir]`. It prints `scope-path : C-NAME - description` without reading bodies. |
| **load** `<ref...>` | Resolve each reference with `scripts/resolve.sh`, then read only that file. Follow related paths lazily. Loading is silent unless the user asks for a summary. |
| **create** `<name> [subject-path]` | Validate a lowercase kebab name, run `list` to avoid duplicates, use `scope.sh` to select the scope, and create `.contexts/<name>.md` from `template.md`. Record the user's intended subject as positive `tracks`. Do not create lifecycle sections. |
| **update** `<ref>` | Resolve the reference, check every candidate fact against `tracks`, and surgically edit only matching facts that changed. Remove stale facts; never append session history or work state. |
| **delete** `<ref>` | Resolve the reference, show its qualified reference, obtain explicit confirmation, then remove only that file. |
| **lint** | Run `scripts/lint.sh [start-dir]`. It validates metadata, scope, size, and forbidden lifecycle or history sections. |

Helper scripts are run with `bash`. References accepted by `resolve.sh` are canonical bare
or qualified references. The lowercase kebab filename is also accepted as an explicit
operation argument, but output and conversational references must use canonical `C-*` form.

## File Format

Use `template.md`. Frontmatter requires `name`, `description`, and a one-line `tracks`. The
description is a discovery hint; `tracks` is the ownership boundary for future updates.

Derive `tracks` positively from what the user says the context must follow. Do not invent an
exclusion list. Ask only when the requested subject has materially different possible boundaries.
Before adding a fact, verify that it directly helps preserve knowledge about that subject. A
related fact is not enough. If it does not fit, leave it out or use another context.

Existing contexts without `tracks` remain readable. The lint reports them as warnings. Before
updating one, propose positive `tracks` from its current durable content and ask the user to confirm
it; then add `tracks` before other content.

Keep contexts at or below 200 lines. The lint warns above 200 and fails above 300. If a context
cannot safely fit, ask for explicit approval before adding or increasing a numeric `max_lines`
frontmatter override above 300. Never add an override merely because the context is already too
large; compact it first and preserve every in-scope durable fact.

Write file and directory references as backtick tokens prefixed with `./`, relative to the
context's scope marker. Do not duplicate facts that are obvious from the referenced source.

During mutation-authorized work, update an existing context without asking when a durable
fact changes and a future reader would otherwise be misled. Execution directives always
control mutation: during a read-only mode, report stale context instead of editing it. Do
not create a new context proactively without user approval.

## Lore Upgrade

Lore is deprecated. When this skill is used in a project, run `scripts/migrate.sh --check`
from the active project root once per session. The check scans for scoped `.lores/`
directories and `AGENTS.md`/`CLAUDE.md` instructions that reference lore.

If the check finds lore directories or instructions, read `references/lore-upgrade.md` and
follow it. Do not infer migration permission from another contexts operation.
