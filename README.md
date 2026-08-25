# agentic-workflow

Composable agent skills for the [open skills ecosystem](https://github.com/vercel-labs/skills).
Together they control execution, organize the current thread, preserve project knowledge, and
make long-running work resumable across sessions and agents.

## Core workflow

| Skill | Role | Lifetime |
|-------|------|----------|
| [`tl-dr`](#tl-dr) | Keep responses answer-first, concise, and technically complete | Current session |
| [`directives`](#directives) | Control what the agent may do now | Current request |
| [`tasks`](#tasks) | Track explicit `T1`/`T-*` work in the current thread | Current thread |
| [`contexts`](#contexts) | Preserve factual `C-*` project knowledge in Git | Long term |
| [`missions`](#missions) | Track outcome-driven `M-*` work in Git | Until completion |
| [`figma-integration`](#figma-integration) | Implement and verify designs through Figma MCP | Current request |
| [`claudie`](#claudie) | Enforce Claude-oriented tool discipline | Current session |

The three work layers stay separate:

```text
M-AUTH                  persistent mission
|-- C-BACKEND           durable factual context
|-- C-INTEGRATION       durable factual context
`-- T1, T2              ephemeral work for the current thread
      `-- GO, PLAN...    execution directives

tl-dr shapes the agent's responses across every layer.
```

Install the workflow:

```bash
npx skills@latest add zouloux/agentic-workflow -g -s tl-dr directives tasks contexts missions figma-integration claudie
```

Projects that want the conversational workflow active in every session can add this to
their `AGENTS.md` or `CLAUDE.md`:

```md
## Agent workflow

Load the `tl-dr`, `directives`, and `tasks` skills before working in this repository.

This project also uses `contexts` and `missions`. Load them when the user invokes them,
references `C-*` or `M-*`, or another project instruction requires them. Do not preload them.

If a requested skill is unavailable, continue and report it.
```

### Thread task

```text
User:
T1: Authentication test fails. Find cause. - EXPLORE

Agent:
The fixture token expires before the request is sent.
No files were changed.

User:
T1: Fix the fixture and verify the test - GO

Agent:
T1 completed. The fixture now creates a fresh token and the test passes.
```

### Long-running mission

```text
User:
M-AUTH STATUS

Agent:
M-AUTH is active.
In progress: refresh-token support.
Blocked: provider sandbox credentials.
Next: complete token rotation tests.
Contexts: C-BACKEND, C-INTEGRATION.

User:
M-AUTH: implement token rotation - GO

Agent:
Token rotation is implemented and verified. M-AUTH now records the updated
current state and the remaining work.
```

### Factual context

```text
User:
C-BACKEND: explain the current session model - ANSWER

Agent:
The backend uses rotating refresh tokens. Each successful rotation invalidates
the previous token, while the session record keeps the active token family ID.
```

## Skill reference

### tl-dr

[`skills/tl-dr/SKILL.md`](skills/tl-dr/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@tl-dr`

Simplified, answer-first responses with natural prose and full technical accuracy. It matches the
requested depth, removes irrelevant detail, and uses Simplified Technical English only where
strict instructions benefit from it. It activates when the user requests concise or simplified
responses, explicitly names the skill, or applicable agent instructions require it. It does not
self-activate merely because a shorter response might be useful. Say `stop tl-dr` to resume the
previous response style. Activation and deactivation are announced once in the current language.

Inspired by these skills:

- [`i-have-adhd`](https://github.com/ayghri/i-have-adhd/blob/main/skills/i-have-adhd/SKILL.md)
- [`unslop`](https://github.com/cursor/plugins/blob/main/pstack/skills/unslop/SKILL.md)
- [`asd-ste100`](https://github.com/danyuchn/asd-ste100-skill/blob/master/SKILL.md)
- [`caveman`](https://github.com/JuliusBrussee/caveman/blob/main/skills/caveman/SKILL.md)

### directives

[`skills/directives/SKILL.md`](skills/directives/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@directives`

Execution-control modes can apply to a whole message or to a syntactically attached request.
Without a directive, the agent behaves normally.

| Directive | Behavior |
|-----------|----------|
| `GO` | Implement or execute the request. |
| `NOGO` | Treat the request as context without implementing it. |
| `EXPLORE` | Investigate thoroughly without mutations. |
| `ASK` | Clarify important uncertainty before acting. |
| `ANSWER` | Answer directly with minimal inspection and no execution or mutation. |
| `WDYT` | Evaluate a proposal and its trade-offs without mutating. |
| `AWG` | Check readiness for `GO` and report only material blockers. |
| `PLAN` | Produce a concrete implementation plan without mutating. |
| `VERIFY` | Verify work performed during the current session. |
| `REVIEW` | Review the complete current implementation without using Git. |
| `FIX` | Fix the most recent relevant review findings. |
| `YN` | Answer with only yes or no. |
| `TERSE` | Make the response extremely concise. |
| `KISS` | Use the smallest correct solution. |
| `HALT` | Stop immediately and report the critical reason. |

`AWG` is a read-only preflight. It answers whether the request has enough information and
permission for `GO`, or reports only the material blockers. It never grants or infers permission,
and all `GO` safety and confirmation rules still apply.

```text
Implement OAuth login. AWG?
```

### tasks

[`skills/tasks/SKILL.md`](skills/tasks/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@tasks`

Ephemeral work items for the current conversation. `T1` and `T2` are the recommended numeric
forms; `T-1` and `T-2` remain equivalent aliases. `NEW TASK`, `nouvelle tâche`, `T?`, and
`T(new)` allocate the next numeric identifier and let the agent derive a short task name. `T1A`
is an independently tracked subtask, while `T1-S1` is the first ordered step of `T1`. Task state
never leaves the thread. `TODO` lists open tasks, `PENDING` defers one, and `CANCEL` closes one
without execution. Question answers and later context reminders use a compact label such as
`T4 - Header Size`.

```text
T1: Explain the failure - ANSWER
T2: Update the parser - GO
NEW TASK: Compare header sizes - ANSWER
T? - Add the mobile breakpoint - GO
T2A: Add the regression test - GO
T2-S1: Update the parser grammar
T2-S2: Verify existing syntax remains compatible
```

### contexts

[`skills/contexts/SKILL.md`](skills/contexts/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@contexts`

Durable knowledge maps stored in scoped `.contexts/` directories. Each `C-*` context declares the
subject it owns, then keeps only current design choices, known problems, rules, and authoritative
files within that boundary. It never contains history, TODOs, or work progress. The skill supports
monorepos, validates contexts with `/contexts lint`, and offers a confirmation-gated migration from
deprecated `.lores/` storage.

### missions

[`skills/missions/SKILL.md`](skills/missions/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@missions`

Durable macro work stored in scoped `.missions/` directories. An `M-*` mission records its
objective, current state, in-progress work, blockers, next actions, nice-to-have items, completion
criteria, and related `C-*` contexts. Use `MISSIONS`, `M-* STATUS`, and `M-* DONE` to manage it.

### figma-integration

[`skills/figma-integration/SKILL.md`](skills/figma-integration/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@figma-integration`

Reusable Figma MCP workflow for validating the selected source, reading design context, mapping
designs to project primitives, recording only useful source nodes beside their styles, and
verifying the result. Without a valid node, it stops and asks the user for the correct selection.
It activates for Figma implementation or comparison work, not incidental mentions.

### claudie

[`skills/claudie/SKILL.md`](skills/claudie/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@claudie`

Claude-oriented tool discipline for repositories that want file operations to use the harness's
dedicated tools instead of Python, shell text processing, redirects, or heredocs. Load it from a
project's `CLAUDE.md` or invoke `/claudie` explicitly.

### afk

[`skills/afk/SKILL.md`](skills/afk/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@afk`

AFK mode for macOS agents, with mobile notifications sent to an iPhone through iCloud Reminders.
The agent alerts you when work completes, needs a decision, or becomes blocked.

## Deprecated skills

### terse

> [!WARNING]
> Deprecated. Use [`tl-dr`](#tl-dr) for new installations.

[`skills/terse/SKILL.md`](skills/terse/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@terse`

Legacy answer-first, minimal-token response style.

### track

> [!WARNING]
> Deprecated. Kept for existing users; avoid new installations.

[github.com/zouloux/agentic-workflow](https://github.com/zouloux/agentic-workflow) · [`skills/track/SKILL.md`](skills/track/SKILL.md)

```
npx skills add -g zouloux/agentic-workflow@track
```

Legacy cross-project TODO tracking in an agent-agnostic store outside repositories.

### lore

> [!WARNING]
> Deprecated. Use [`contexts`](#contexts), its direct replacement, for new installations.

[github.com/zouloux/agentic-workflow](https://github.com/zouloux/agentic-workflow) · [`skills/lore/SKILL.md`](skills/lore/SKILL.md)

```
npx skills add -g zouloux/agentic-workflow@lore
```

Legacy per-topic lore files stored in `.lores/` directories. Kept for existing users; the
contexts skill provides a confirmation-gated migration to `.contexts/`.

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

## Update or uninstall a skill

Remove a globally installed skill:

```bash
npx skills remove -g tl-dr
```

Update it from the repository without prompts:

```bash
npx -y skills@latest update tl-dr -g -y
```

## Update all

```bash
npx -y skills@latest update -g -y
```

Updates only apply to installed skills. To install newly published workflow skills, run the
installation command above again.
