# agentic-workflow

Agent skills for the [open skills ecosystem](https://github.com/vercel-labs/skills).

## lore

[github.com/zouloux/agentic-workflow](https://github.com/zouloux/agentic-workflow) · [`skills/lore/SKILL.md`](skills/lore/SKILL.md)

```
npx skills add -g zouloux/agentic-workflow@lore
```

Lightweight per-topic **lore** files — living, evolving notes on a subject — stored in a
project's `.lores/` directories, so an agent can resume work without a full briefing. One
small file per topic: a map (relevant files + non-obvious decisions), not a manual.
Token-minimal, facts auto-save, scoped for monorepos, no manual index.

## notify

[github.com/zouloux/agentic-workflow](https://github.com/zouloux/agentic-workflow) · [`skills/notify/SKILL.md`](skills/notify/SKILL.md)

```
npx skills add -g zouloux/agentic-workflow@notify
```

Mobile notifications from macOS agents to an iPhone through iCloud Reminders — no
third-party service or server. The skill works immediately after installation: ask an
agent to notify you when work completes or needs attention. The latest alert stays
in the dedicated `Agents` list until the next one replaces it.

## terse

[github.com/zouloux/agentic-workflow](https://github.com/zouloux/agentic-workflow) · [`skills/terse/SKILL.md`](skills/terse/SKILL.md)

```
npx skills add -g zouloux/agentic-workflow@terse
```

Answer-first, minimal-token output: the important info fits one non-scrolling screen, no
filler. Leads with the answer or next action, numbers multi-step work, tracks state in one
line. Activates only on explicit request (`/terse`, or asking for a concise/brief answer) —
never auto-triggers.

## track (deprecated)

> [!WARNING]
> Deprecated. Kept for existing users; avoid new installations.

[github.com/zouloux/agentic-workflow](https://github.com/zouloux/agentic-workflow) · [`skills/track/SKILL.md`](skills/track/SKILL.md)

```
npx skills add -g zouloux/agentic-workflow@track
```

Cross-project TODO tracking in a store **outside** your repos, so tasks survive branch
switches and never pollute the working tree. One markdown file per project, each task
tagged with its branch + date. List all tasks in a project, or just the current branch
(`/track branch`), or every project at once (`/track all`). Agent-agnostic store under
`${XDG_DATA_HOME:-~/.local/share}/track` (override with `$TRACK_DIR`).

## Trusted third-party skills

Skills I've audited and use. **Install per project** (no `-g`) so they only load where the
stack is relevant. Links point to source — review before installing; "trusted" means the
version I read, not a guarantee of future updates.

| Skill | Source | Install |
|-------|--------|---------|
| building-components | [vercel/components.build](https://github.com/vercel/components.build) | `npx skills add vercel/components.build@building-components` |
| next-best-practices | [vercel/nextjs-skills](https://github.com/vercel/nextjs-skills) | `npx skills add vercel/nextjs-skills@next-best-practices` |
| tailwind-best-practices | [ofershap/tailwind-best-practices](https://github.com/ofershap/tailwind-best-practices) | `npx skills add ofershap/tailwind-best-practices@tailwind-best-practices` |
| deploy-to-vercel | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `npx skills add vercel-labs/agent-skills@deploy-to-vercel` |
| turborepo | [vercel/turborepo](https://github.com/vercel/turborepo) | `npx skills add vercel/turborepo@turborepo` |
| vercel-react-best-practices | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `npx skills add vercel-labs/agent-skills@vercel-react-best-practices` |
| vercel-react-native-skills | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `npx skills add vercel-labs/agent-skills@vercel-react-native-skills` |
| web-design-guidelines | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `npx skills add vercel-labs/agent-skills@web-design-guidelines` |
