# agentic-workflow

Agent skills for the [open skills ecosystem](https://github.com/vercel-labs/skills).

## lore

Lightweight per-topic **lore** files — living, evolving notes on a subject — stored in a
project's `.lores/` directories, so an agent can resume work on a subject without a full
briefing. One small file per topic: a map (relevant files + non-obvious decisions), not a
manual.

Install it into a project:

```
npx skills add zouloux/agentic-workflow --skill lore
```

Then ask your agent to `init` it, and to `/lore list` / `load` / `create` / `clean` as you
work. Key ideas:

- **Token-minimal** — loading a lore reads one small file; related files are followed
  lazily, on demand, and the load is acknowledged in one line (no re-summarizing).
- **Facts auto-save, cleanup is proposed** — information is persisted at checkpoints
  without prompting (reviewed via `git diff`); reorganizing is offered or done on request.
- **Scoped for monorepos** — lore lives next to the nearest `AGENTS.md`/`CLAUDE.md`; reads
  scan downward from the CWD, writes anchor to the nearest scope.
- **No manual index** — `list` reads each file's frontmatter, so it never drifts.

See [`skills/lore/SKILL.md`](skills/lore/SKILL.md) for the full behavior.
