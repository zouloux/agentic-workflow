---
name: <kebab-name>
description: <one line — what this lore covers; shown in `list`>
status: active
---

# Lore: <Subject Name>

## Topic

One paragraph: what this lore covers, the current approach, and why it exists.

## Current state

Short summary of what works, what is pending, what is fragile, and what an agent should
know when resuming work.

## Key decisions

- Architectural choices, conventions, constraints, and important "why" decisions.

## Boundaries

- Non-obvious limits, traps, and assumptions agents often get wrong. Prefer positive,
  factual statements over vague prohibitions.

## Related files

<!-- File paths: prefix `./` and write them relative to THIS lore's scope marker
     (nearest AGENTS.md/CLAUDE.md) — e.g. `./src/foo.ts`, not `./apps/app-1/src/foo.ts`.
     status.sh validates every `./…` ref. Globs (`*`) are NOT validated: omit the `./`. -->
- `./src/path/to/file.ts` — short description

## Related documentation

- `./docs/path/to/doc.md` — short description

## Tasks

- [ ] Pending work only. Done tasks are removed, not kept (git has the history).

## Update when

- Events that should trigger updating this lore.
