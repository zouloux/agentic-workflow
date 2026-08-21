---
name: contexts
description: >
  Create, load, update, delete, and migrate durable factual context maps stored in scoped
  .contexts directories. Use when the user mentions contexts, references C-<NAME>, asks to
  preserve system knowledge, or when a project still uses the deprecated lore format.
---

# Contexts

Contexts are small, durable factual maps for systems and subjects. Each context lives at
`<scope>/.contexts/<name>.md` and has the canonical reference `C-<UPPER-KEBAB-NAME>`.
For example, `.contexts/deploy-routing.md` is `C-DEPLOY-ROUTING`.

A context records only:

- current system state;
- decisions and their durable reasons;
- boundaries, invariants, and constraints;
- related files and documentation.

Contexts are never work tracking. Do not store TODOs, progress, in-progress or blocked
states, next actions, nice-to-have items, plans, or any other work lifecycle information.
If such information appears during an update, leave it out rather than translating it.

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
| **create** `<name> [subject-path]` | Validate a lowercase kebab name, run `list` to avoid duplicates, use `scope.sh` to select the scope, and create `.contexts/<name>.md` from `template.md`. Do not create lifecycle sections. |
| **update** `<ref>` | Resolve the reference and surgically edit only factual sections that changed. Remove stale facts; never append session history or work state. |
| **delete** `<ref>` | Resolve the reference, show its qualified reference, obtain explicit confirmation, then remove only that file. |

Helper scripts are run with `bash`. References accepted by `resolve.sh` are canonical bare
or qualified references. The lowercase kebab filename is also accepted as an explicit
operation argument, but output and conversational references must use canonical `C-*` form.

## File Format

Use `template.md`. Keep frontmatter to `name` and `description`; keep the body concise.
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

If either exists, propose an upgrade and wait for explicit user confirmation. Never run
`--apply` automatically. After confirmation, run `scripts/migrate.sh --apply` from the same
root. The script:

1. checks every migration and reports all collisions before changing anything;
2. renames each scoped `.lores/` directory to `.contexts/`;
3. renames every `*.lore.md` below it to `*.md`;
4. adjusts only the migrated `.lores` and `.lore.md` path strings;
5. mechanically changes lore references to contexts in the relevant scope markers.

Migration does not clean up, summarize, reorganize, or otherwise rewrite document content
beyond those path adjustments. Legacy lifecycle content can therefore remain after migration;
do not silently remove it. Review or cleanup is a separate user-authorized operation. If
preflight reports a collision or an unscoped `.lores/` directory, report it and stop without
mutation.
