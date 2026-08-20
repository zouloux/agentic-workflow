---
name: directives
description: >
  Execution-control keywords EXPLORE/explore, ASK/ask, NO GO/no go/no-go,
  WDYT/wdyt, GO/go, PLAN/plan, VERIFY/verify, REVIEW/review, and FIX/fix.
  MUST load when an uppercase keyword is used as an order. May load for a lowercase
  keyword only when it is clearly used as an order, never when it appears in ordinary prose.
---

# Directives

Interpret the user's execution-control keywords. Apply them without repeating the keyword or announcing a mode unless a clarification is necessary.

## Detection

- An uppercase keyword used as an order is mandatory. Load this skill and apply it.
- A lowercase or mixed-case keyword may trigger this skill only when it is clearly an order, such as a standalone instruction, an imperative, or a suffix attached to a task.
- A keyword mentioned in ordinary prose is not an order.
- Without a directive, follow the normal agent behavior.

Recognize punctuation and common separators without changing meaning, including `WDYT?`, `NO-GO`, and task suffixes such as `-> GO`.

## Scope

- A directive attached to a task applies only to that task.
- A standalone directive applies to the whole message.
- A task-specific directive overrides a message-wide directive for that task.
- The last directive replaces earlier directives only within the same scope.
- When a message contains multiple tasks with different directives, handle each task under its own directive. Never transfer permission to mutate from one task to another.

If the scope cannot be determined safely, ask one short question before mutating anything.

## Keywords

### EXPLORE

Inspect the repository, supplied links, and relevant context thoroughly. Use read-only tools. Do not mutate files, Git state, external systems, or persistent data. Do not use subagents unless the user explicitly requests them.

### ASK

Answer the question directly and simply. Explore only when necessary for an accurate answer. Do not mutate anything.

### NO GO

Treat the message as context or a proposed task. Study it briefly and respond, but do not implement it or mutate anything. Avoid broad exploration unless it is needed to understand the context.

### WDYT

Evaluate the user's proposal and give a clear opinion. Explore as for `EXPLORE`, verify relevant impacts and trade-offs, and do not mutate anything. Do not overengineer hypothetical concerns.

### GO

Implement the scoped task or execute its requested actions. Do not ask for confirmation when the task is clear and safe. Ask for explicit confirmation before destructive, irreversible, or high-impact actions.

### PLAN

Explore as needed and produce a concrete implementation plan. Do not mutate anything.

### VERIFY

Verify only the work performed during the current session. Inspect the affected files and run relevant checks that are not expected to alter source files or persistent state. Report results without fixing failures.

### REVIEW

Review all current Git changes in the repository, not only work from the current session. Include staged and unstaged changes. Review commits only when the user identifies a range, branch, or pull request. Report findings first and do not mutate anything.

### FIX

Fix the issues listed in the most recent relevant agent response. Mutation is authorized only for those issues and their necessary verification. Do not start a new broad review. If the target findings are missing or ambiguous, ask which issues to fix. Confirm before any destructive or irreversible correction.
