---
name: directives
description: >
  Execution-control modes EXPLORE/explore, ASK/ask, ANSWER/answer, NOGO,
  NO GO, WDYT/wdyt, WDYL/wdyl, AWG/awg, GO/go, PLAN/plan, VERIFY/verify,
  REVIEW/review, FIX/fix, YN/yn, TERSE/terse, KISS/kiss, and HALT/halt.
  MUST load when an uppercase mode is used as an order. May load for a
  lowercase mode only when it is clearly used as an order, never when it
  appears in ordinary prose.
---

# Directives

Interpret the user's execution-control modes. Apply them without repeating the mode unless clarification is necessary.

## Activation

On activation, list the available directives once, without descriptions, in the current language: `GO`, `NOGO`, `EXPLORE`, `ASK`, `ANSWER`, `WDYT`, `WDYL`, `AWG`, `PLAN`, `VERIFY`, `REVIEW`, `FIX`, `YN`, `TERSE`, `KISS`, `HALT`. Do not repeat this list while the skill remains active.

When the user explicitly disables the skill, announce the equivalent of "Directives disabled" once in the current language and stop applying it. If the skill is activated again later, list the available directives once again.

## Detection

- An uppercase mode used as an order is mandatory. Load this skill and apply it.
- A lowercase or mixed-case mode may trigger this skill only when it is clearly an order, such as a standalone instruction, an imperative, or a syntactically attached suffix.
- A mode mentioned in ordinary prose is not an order.
- Without a directive, follow normal agent behavior.

Recognize punctuation and common separators without changing meaning, including suffixes such as `-> GO` or `- ANSWER`. Treat `NO GO` and `NO-GO` as aliases for `NOGO`.

## Classes And Priority

- `HALT` has the highest directive priority and stops all further work in its scope.
- `GO`, `NOGO`, `EXPLORE`, `ASK`, `ANSWER`, `WDYT`, `WDYL`, `AWG`, `PLAN`, `VERIFY`, `REVIEW`, and `FIX` select execution behavior.
- `KISS` constrains the solution. `YN` and `TERSE` constrain the response.
- Constraints compose with an execution mode but never grant permission to inspect, execute, or mutate.
- Safety requirements and explicit confirmation requirements still apply in every mode.

## Attachment And Scope

Other skills may declare labeled request syntax and prefixes. The declaring skill owns recognition and meaning for every prefix it declares. This skill does not maintain a central plugin or prefix registry.

Determine directive scope from syntactic attachment:

- A directive inside or appended to a recognized declaration applies only to that declaration.
- A directive in the same list item or sentence applies to the nearest request when punctuation or a separator clearly joins them.
- A standalone directive applies to the whole message.
- A locally attached directive overrides a message-wide directive of the same class for its request.
- The last execution mode replaces earlier execution modes only within the same scope, unless a mode definition explicitly allows composition.
- `YN`, `TERSE`, and `KISS` compose with each other and with the selected execution mode.
- `HALT` overrides every other directive in the same scope.
- Different requests may carry different directives. Never transfer authorization to mutate between them.

Use declaration boundaries supplied by the skill that recognizes the declaration. No integration entry is needed here. If scope cannot be determined safely, ask one short question before mutating anything.

## Modes

### HALT

Stop the scoped work immediately. Do not start another tool call, mutation, or execution step in that scope. Notify the user of the critical reason for the stop and report any partial state or side effect that already occurred. Do not resume until the user gives a new explicit instruction.

### GO

Implement the scoped request or execute its requested actions. Ask questions only when blocked or when major uncertainty could materially change the result. Otherwise, proceed without confirmation when the request is clear and safe. Ask for explicit confirmation before destructive, irreversible, or high-impact actions.

### NOGO

Treat the scoped input as information or a proposal. Study it briefly and respond, but do not implement it or mutate anything. Avoid broad exploration unless needed to understand the input.

### EXPLORE

Inspect the repository, supplied links, and relevant material thoroughly. Use read-only tools. Ask focused questions when the available code and information are insufficient, or when an answer could avoid substantial research. If the investigation becomes too long, repeats searches, or stops making useful progress, stop it, report what is missing or uncertain, and ask for the information needed to continue. Do not mutate files, Git state, external systems, or persistent data. Do not use subagents unless the user explicitly requests them.

### ASK

Clarify the scoped request with the user before acting. Inspect available information briefly when it can produce better questions, then ask only the focused questions needed to resolve important uncertainty. Do not mutate anything until the user answers.

### ANSWER

Answer the scoped question directly. Inspect only the minimum material necessary for an accurate answer. Do not explore broadly, execute requested actions, or mutate files, external systems, or persistent state.

### WDYT

Evaluate the scoped proposal and give a clear opinion. Explore as for `EXPLORE`, verify relevant impacts and trade-offs, and do not mutate files, external systems, or persistent state. Do not overengineer hypothetical concerns.

### AWG

Check whether the scoped request has enough information, permission, and relevant context to proceed safely with `GO`. Inspect available material only as much as needed for this readiness check. Do not mutate anything.

- If ready, answer clearly that the request is ready.
- If not ready, list only the missing information, decisions, permissions, or dependencies that materially block execution.
- State reasonable non-blocking assumptions instead of asking for unnecessary preferences.
- Do not produce a full plan or start implementation unless separately authorized.

When the user writes `AWG GO`, or explicitly makes `GO` conditional on readiness such as `AWG? If yes, GO`, treat `AWG` as a guard. If a user answer is materially required, do not mutate and ask only the focused blocking question. Otherwise, execute `GO` immediately. `AWG` cannot infer or grant permission, and guarded execution remains subject to every confirmation and safety rule of `GO`. Without `GO` or another explicit condition, `AWG` remains a read-only readiness check and a later standalone `GO` is required.

### PLAN

Explore as needed and produce a concrete implementation plan. Do not mutate anything.

### VERIFY

Verify only work performed during the current session. Inspect affected files and run relevant checks that are not expected to alter source files or persistent state. Report results without fixing failures.

### WDYL

Review the current conversation and return candidates for durable knowledge learned during the
session. Do not mutate files, external systems, or persistent data.

- Include current, reusable, non-obvious facts learned from user corrections, explicit decisions,
  or manual changes reported by the user.
- Include independently inferred missing context only when consistent project conventions or an
  authoritative source provide sufficient evidence. Do not present unsupported assumptions as
  learnings.
- Exclude temporary work state, completed actions, generic observations, and implementation details
  that are obvious from the source.
- Number candidates as `L-1`, `L-2`, and so on. List user-grounded learnings first. Put agent-inferred
  learnings last and mark each one `[inferred]` in the current language.
- Keep candidates ephemeral within the current conversation. Never persist them automatically.
- If there are no durable learnings, state that directly instead of inventing candidates.

### REVIEW

Review the scoped feature, file, or area as it currently exists in the repository. Evaluate its complete implementation, behavior, and relevant integrations, not only recent changes. Do not inspect Git state, diffs, or history. If the review scope is missing or ambiguous, ask the user to identify it. Report findings first and do not mutate anything.

### FIX

Fix the issues listed in the most recent relevant agent response. Mutation is authorized only for those issues and their necessary verification. Do not start a new broad review. If the target findings are missing or ambiguous, ask which issues to fix. Confirm before any destructive or irreversible correction.

## Constraints

### YN

Answer the scoped yes-or-no question with exactly the current-language equivalent of `yes` or `no`. Output no explanation, qualification, punctuation, formatting, or additional words. `YN` does not authorize execution or mutation.

### TERSE

Make the scoped response extremely concise while preserving the answer, critical blockers, and required safety information. Prefer one short sentence, a minimal state line, or the smallest useful code or command. Do not add a preamble, recap, optional detail, or closing offer. `TERSE` applies only to the response and does not change execution behavior.

### KISS

Use the smallest correct solution for the scoped work. Remove or avoid unjustified abstractions, helpers, configuration, compatibility layers, and speculative flexibility. Preserve requirements, correctness, safety, and necessary verification. `KISS` constrains the approach but does not authorize mutation.
