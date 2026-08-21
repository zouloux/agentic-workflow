---
name: directives
description: >
  Execution-control keywords PENDING/pending, TODO/todo, EXPLORE/explore, ASK/ask,
  ANSWER/answer, NOGO, NO GO, WDYT/wdyt, GO/go, PLAN/plan, VERIFY/verify,
  REVIEW/review, and FIX/fix.
  Also manages task identifiers such as T-1, T-1A, and T-AUTH.
  MUST load when an uppercase keyword is used as an order or a canonical task declaration
  starts with T-. May load for a lowercase keyword only when it is clearly used as an order,
  never when it appears in ordinary prose.
---

# Directives

Interpret the user's execution-control keywords. Apply them without repeating the keyword unless a clarification is necessary.

## Activation

On activation, list the available directives once, without descriptions, in the current language: `PENDING`, `TODO`, `EXPLORE`, `ASK`, `ANSWER`, `NOGO`, `WDYT`, `GO`, `PLAN`, `VERIFY`, `REVIEW`, `FIX`. Do not repeat this list while the skill remains active.

When the user explicitly disables the skill, announce the equivalent of "Directives disabled" once in the current language and stop applying it. If the skill is activated again later, list the available directives once again.

## Detection

- An uppercase keyword used as an order is mandatory. Load this skill and apply it.
- A canonical `T-<ID>.` or `T-<ID>:` task declaration at the start of a line or list item is mandatory. Load this skill and track the tasks.
- A lowercase or mixed-case keyword may trigger this skill only when it is clearly an order, such as a standalone instruction, an imperative, or a suffix attached to a task.
- A keyword mentioned in ordinary prose is not an order.
- Without a directive, follow the normal agent behavior.

Recognize punctuation and common separators without changing meaning, including `WDYT?` and task suffixes such as `-> GO` or `- ANSWER`. Treat `NO GO` and `NO-GO` as aliases for `NOGO`.

## Scope

- A directive attached to a task applies only to that task.
- A standalone directive applies to the whole message.
- A task-specific directive overrides a message-wide directive for that task.
- The last directive replaces earlier directives only within the same scope.
- When a message contains multiple tasks with different directives, handle each task under its own directive. Never transfer permission to mutate from one task to another.

If the scope cannot be determined safely, ask one short question before mutating anything.

## Tasks

Use explicit task identifiers to keep multi-task requests and responses easy to reference.

### Syntax

- A task declaration starts a line or list item with `T-<ID>`, followed by `.` or `:` and its description.
- Use numeric IDs for ordered tasks: `T-1`, `T-2`, and so on.
- Use a dotted suffix for a reply or discussion point attached to a subject: `T-1.1`, `T-1.2`, and so on. It is not a separate tracked task unless the user makes it one explicitly.
- Append an uppercase letter for a direct tracked subtask with its own lifecycle: `T-1A`, `T-1B`, and so on.
- Use an uppercase name for a stable topic: `T-AUTH`, `T-API`, or `T-AUTH-API`.
- A task ID mentioned inside a sentence is a reference, not a new declaration.
- Preserve user-defined IDs exactly. Never renumber or reuse them within the conversation.
- Let the user and agent use these relationships naturally. Ask for clarification only when the distinction changes scope, permissions, or execution.

Examples:

```text
T-1. Explain the failure - ANSWER
T-2: Update the parser - GO
T-2A. Add the regression test - GO
T-AUTH: Review the authentication flow - REVIEW
```

### Lifecycle

- Identify all declared tasks before handling them. A directive attached to a task follows the scope rules above.
- Track each task as pending, in progress, completed, blocked, or canceled while it remains relevant to the conversation.
- Refer to tasks by ID when reporting progress, completion, blockers, dependencies, or a shared cause.
- Handle tasks independently. A blocked task does not prevent work on another task unless they depend on each other.
- Mark a task completed only after its requested outcome and necessary verification are complete.
- The agent may add a task when new required work is discovered. Use the next unused numeric ID for an independent task or the next unused letter for a direct subtask, state why it was added, and mark it pending.
- Do not act on an agent-created task until the user authorizes it with a directive or a direct instruction.
- After `ANSWER` or `WDYT`, add a concise pending task when the response identifies a concrete next action worth tracking. Use one line for a simple follow-up and a separate section only for multiple or complex follow-ups. Do not invent a task when the answer has no useful next action.
- Do not create task entries for routine implementation steps or persist the task list outside the conversation unless the user asks.

## Keywords

### PENDING

Leave the scoped task pending. Do not inspect, answer, execute, or mutate for that task until the user gives it another directive or direct instruction.

### TODO

List all known tracked tasks in the conversation that are not completed or canceled. Include pending, in-progress, blocked, and proposed tasks. Show each task's ID, status, and a short description without executing or mutating it. If none remain, say so. Do not treat the absence of `GO` alone as evidence that a task remains: an `ANSWER` or `WDYT` task can be complete after its response.

### EXPLORE

Inspect the repository, supplied links, and relevant context thoroughly. Use read-only tools. Ask focused questions when the available code and context are insufficient, or when an answer could avoid substantial research. If the investigation becomes too long, repeats searches, or stops making useful progress, stop it, report what is missing or uncertain, and ask the user for the information needed to continue. Do not mutate files, Git state, external systems, or persistent data. Do not use subagents unless the user explicitly requests them.

### ASK

Clarify the task with the user before acting. Inspect the context briefly when it can produce better questions, then ask only the focused questions needed to resolve important uncertainty. Do not mutate anything until the user answers.

### ANSWER

Answer the scoped question directly. Inspect only when necessary for an accurate answer. Do not execute requested actions or mutate files, external systems, or persistent state. A pending follow-up task proposed under the task lifecycle rules is allowed.

### NOGO

Treat the message as context or a proposed task. Study it briefly and respond, but do not implement it or mutate anything. Avoid broad exploration unless it is needed to understand the context.

### WDYT

Evaluate the user's proposal and give a clear opinion. Explore as for `EXPLORE`, verify relevant impacts and trade-offs, and do not mutate files, external systems, or persistent state. A pending follow-up task proposed under the task lifecycle rules is allowed. Do not overengineer hypothetical concerns.

### GO

Implement the scoped task or execute its requested actions. Ask questions only when blocked or when major uncertainty could materially change the result. Otherwise, proceed without confirmation when the task is clear and safe. Ask for explicit confirmation before destructive, irreversible, or high-impact actions.

### PLAN

Explore as needed and produce a concrete implementation plan. Do not mutate anything.

### VERIFY

Verify only the work performed during the current session. Inspect the affected files and run relevant checks that are not expected to alter source files or persistent state. Report results without fixing failures.

### REVIEW

Review the requested feature, file, or area as it currently exists in the repository. Evaluate its complete implementation, behavior, and relevant integrations, not only recent changes. Do not inspect Git state, diffs, or history. If the review scope is missing or ambiguous, ask the user to identify it. Report findings first and do not mutate anything.

### FIX

Fix the issues listed in the most recent relevant agent response. Mutation is authorized only for those issues and their necessary verification. Do not start a new broad review. If the target findings are missing or ambiguous, ask which issues to fix. Confirm before any destructive or irreversible correction.
