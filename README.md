# agentic-workflow

Agent skills for the [open skills ecosystem](https://github.com/vercel-labs/skills).

## contexts

Lightweight topic **context maps** stored in a project's `.contexts/` directory, so an
agent can resume work on a topic without a full briefing. One small file per topic — a
map (relevant files + non-obvious decisions), not a manual.

Install it into a project:

```
npx skills add zouloux/agentic-workflow --skill contexts
```

Then ask your agent to `init` it, and to list / load / create / clean contexts as you
work. Key ideas:

- **Token-minimal** — loading a context reads one small file; related files are followed
  lazily, on demand.
- **Facts auto-save, cleanup is proposed** — information is persisted at checkpoints
  without prompting (reviewed via `git diff`); reorganizing is offered or done on request.
- **Scoped for monorepos** — contexts live next to the nearest `AGENTS.md`/`CLAUDE.md`;
  reads scan downward from the CWD, writes anchor to the nearest scope.
- **No manual index** — `list` reads each file's frontmatter, so it never drifts.

See [`skills/contexts/SKILL.md`](skills/contexts/SKILL.md) for the full behavior.
