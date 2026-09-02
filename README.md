# agentic-workflow

Composable agent skills for the [open skills ecosystem](https://github.com/vercel-labs/skills).
Together they control execution, organize the current thread, preserve project knowledge, and
make long-running work resumable across sessions and agents.

## Core workflow

| Skill                                     | Role                                                           | Lifetime         |
|-------------------------------------------|----------------------------------------------------------------|------------------|
| [`tl-dr`](#tl-dr)                         | Keep responses answer-first, concise, and technically complete | Current session  |
| [`claudie`](#claudie)                     | Improve Claude response and tool discipline                    | Current session  |
| [`directives`](#directives)               | Control what the agent may do now                              | Current request  |
| [`tasks`](#tasks)                         | Track explicit `T1`/`T-*` work in the current thread           | Current thread   |
| [`contexts`](#contexts)                   | Preserve factual `C-*` project knowledge in Git                | Long term        |
| [`missions`](#missions)                   | Track outcome-driven `M-*` work in Git                         | Until completion |
| [`safe-coding`](#safe-coding)             | Add portable behavioral safety around agent operations         | Current session  |
| [`clean-code`](#clean-code)               | Apply stack-aware source and styling conventions               | Current session  |
| [`figma-integration`](#figma-integration) | Implement and verify designs through Figma MCP                 | Current request  |
| [`afk`](#afk)                             | Send mobile notifications while the user is away               | Current session  |

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
npx skills@latest add zouloux/agentic-workflow -g -s tl-dr claudie directives tasks contexts missions safe-coding clean-code figma-integration afk
```

Projects that want the conversational workflow active in every session can add this to
their `AGENTS.md` or `CLAUDE.md`:

```md
## Agent workflow

Load the `tl-dr`, `directives`, `tasks`, `safe-coding`, and `clean-code` skills before working in
this repository.

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

### claudie

[`skills/claudie/SKILL.md`](skills/claudie/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@claudie`

Claude-oriented response and tool discipline. It counters response-length imitation, keeps concise
formats available, and requires file operations to use the harness's dedicated tools instead of
Python, shell text processing, redirects, or heredocs. Load it from a project's `CLAUDE.md` or
invoke `/claudie` explicitly.

### directives

[`skills/directives/SKILL.md`](skills/directives/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@directives`

Directives can apply to a whole message or to a syntactically attached request.
Without a directive, the agent behaves normally.

| Directive      | Behavior                                                                      |
|----------------|-------------------------------------------------------------------------------|
| `HELP`         | List every available directive in a localized Markdown table.                 |
| `GO`           | Implement or execute the request.                                             |
| `NOGO`         | Treat the request as context without implementing it.                         |
| `EXPLORE`      | Investigate thoroughly without mutations.                                     |
| `ASK`          | Clarify important uncertainty before acting.                                  |
| `ANSWER`       | Answer directly with minimal inspection and no execution or mutation.         |
| `WDYT`         | Evaluate a proposal and its trade-offs without mutating.                      |
| `AWG`          | Check readiness for `GO` and report only material blockers.                   |
| `PLAN`         | Produce a concrete implementation plan without mutating.                      |
| `META`         | Show the proposed code transformation, affected source, and data flow.        |
| `BLAST-RADIUS` | Estimate affected files, functions, and line deltas.                          |
| `VERIFY`       | Verify work performed during the current session.                             |
| `WDYL`         | Return ephemeral candidates for durable knowledge learned during the session. |
| `REVIEW`       | Review the complete current implementation without using Git.                 |
| `FIX`          | Fix the most recent relevant review findings.                                 |
| `YN`           | Answer with only yes or no.                                                   |
| `TERSE`        | Make the response extremely concise.                                          |
| `KISS`         | Use the smallest correct solution.                                            |
| `TABLE`        | Format the result as a Markdown table.                                        |
| `HALT`         | Stop immediately and report the critical reason.                              |

`HELP` replaces automatic directive listing when the skill loads. It returns the complete list in
the current conversation language.

`AWG` is a read-only preflight. It answers whether the request has enough information and
permission for `GO`, or reports only the material blockers. It never grants or infers permission,
and all `GO` safety and confirmation rules still apply.

```text
Implement OAuth login. AWG?
```

`META` explains the intended source transformation rather than the agent's editing process. It
identifies affected files and functions, relevant structural changes, and the resulting data flow.
The agent chooses the clearest representation for the task.

`BLAST-RADIUS` provides a smaller structural estimate:

```text
code.helper.ts
~ checkAll() -> +10~15L
~ verifyErrors() -> +2L
+ validate() -> +5L
- removedFunction() -> -50L
```

`HALT` can guard execution with a condition. It stops only when that condition becomes true and
always reports the trigger. An associated task becomes blocked:

```text
T3 - Update migration - HALT
Condition: schema file is missing.
No files were changed.
```

`TABLE` changes only presentation and composes with commands such as `TODO`:

```text
TODO TABLE
```

| ID | Task             | Status  | Description                                            |
|----|------------------|---------|--------------------------------------------------------|
| T1 | Add META         | PENDING | Show the proposed source transformation and data flow. |
| T3 | Update migration | BLOCKED | The schema file is missing.                            |

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

`TODO` lists only open tasks and keeps each description to three lines or fewer:

```text
T1 - Add META directive - PENDING
Show the proposed source transformation clearly.
Include affected files, functions, and data flow.
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

### safe-coding

[`skills/safe-coding/SKILL.md`](skills/safe-coding/SKILL.md) |
`npx skills add -g zouloux/agentic-workflow@safe-coding`

Portable behavioral safety for filesystem boundaries, Git operations, destructive commands,
prompt injection, and concurrent worktrees. It complements harness permissions without weakening
or bypassing them. Natural grants such as `ALLOW R ../other-repo`, `ALLOW RW ~/Downloads`,
`ALLOW git stash`, and `ALLOW git` authorize additional capabilities for the current session.
When permission is missing or an operation remains materially unsafe, the agent must `HALT` and
ask the user instead of finding a workaround.

### clean-code

[`skills/clean-code/SKILL.md`](skills/clean-code/SKILL.md) |
`npx skills add -g zouloux/agentic-workflow@clean-code`

Stack-aware coding conventions for comments, React component structure, CSS Modules, and BEM.
React, CSS Modules, and BEM rules apply independently, so the skill does not introduce a technology
that the target project does not use. It keeps comments intentional, standardizes visual component
roots and props, extracts complex JSX list callbacks, and places component-level styling modifiers
on the root whenever possible.

### figma-integration

[`skills/figma-integration/SKILL.md`](skills/figma-integration/SKILL.md) |
`npx skills add -g zouloux/agentic-workflow@figma-integration`

Reusable Figma MCP workflow for validating the selected source, reading design context, mapping
designs to project primitives, preserving exact visual values and design-variable semantics,
recording only useful source nodes beside their styles, and verifying the result. It never invents
design props or visual treatments. Without a valid node or a required variable mapping, it stops
and asks for the missing source. It loads `clean-code` when available for source conventions and
activates for Figma implementation or comparison work, not incidental mentions.

### afk

[`skills/afk/SKILL.md`](skills/afk/SKILL.md) | `npx skills add -g zouloux/agentic-workflow@afk`

AFK mode for macOS agents, with mobile notifications sent to an iPhone through iCloud Reminders.
The agent alerts you when work completes, needs a decision, or becomes blocked.

## Trusted third-party skills

Skills I've audited and use. **Install per project** (no `-g`) so they only load where the
stack is relevant. Links point to source — review before installing; "trusted" means the
version I read, not a guarantee of future updates.

| Skill                       | Source                                                                                  | Install                                                                   |
|-----------------------------|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| building-components         | [vercel/components.build](https://github.com/vercel/components.build)                   | `npx skills add vercel/components.build@building-components`              |
| next-best-practices         | [vercel/nextjs-skills](https://github.com/vercel/nextjs-skills)                         | `npx skills add vercel/nextjs-skills@next-best-practices`                 |
| tailwind-best-practices     | [ofershap/tailwind-best-practices](https://github.com/ofershap/tailwind-best-practices) | `npx skills add ofershap/tailwind-best-practices@tailwind-best-practices` |
| deploy-to-vercel            | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)                 | `npx skills add vercel-labs/agent-skills@deploy-to-vercel`                |
| turborepo                   | [vercel/turborepo](https://github.com/vercel/turborepo)                                 | `npx skills add vercel/turborepo@turborepo`                               |
| vercel-react-best-practices | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)                 | `npx skills add vercel-labs/agent-skills@vercel-react-best-practices`     |
| vercel-react-native-skills  | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)                 | `npx skills add vercel-labs/agent-skills@vercel-react-native-skills`      |
| web-design-guidelines       | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills)                 | `npx skills add vercel-labs/agent-skills@web-design-guidelines`           |

## Update or uninstall a skill

Remove a globally installed skill:

```bash
npx skills remove -g tl-dr
```

Update it from the repository without prompts:

```bash
npx -y skills@latest update tl-dr -g -y
```

For example, update the source-convention and Figma integration skills directly:

```bash
npx -y skills@latest update clean-code -g -y
npx -y skills@latest update figma-integration -g -y
```

## Update all

```bash
npx -y skills@latest update -g -y
```

Updates only apply to installed skills. To install newly published workflow skills, run the
installation command above again.
