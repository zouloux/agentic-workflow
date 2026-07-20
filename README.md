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

## terse

[github.com/zouloux/agentic-workflow](https://github.com/zouloux/agentic-workflow) · [`skills/terse/SKILL.md`](skills/terse/SKILL.md)

```
npx skills add -g zouloux/agentic-workflow@terse
```

Answer-first, minimal-token output: the important info fits one non-scrolling screen, no
filler. Leads with the answer or next action, numbers multi-step work, tracks state in one
line. Activates only on explicit request (`/terse`, or asking for a concise/brief answer) —
never auto-triggers.

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
