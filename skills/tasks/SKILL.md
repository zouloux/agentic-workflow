---
name: tasks
description: >
  Tracks ephemeral current-thread T1/T-* work items, automatic new-task
  declarations, subtasks, ordered steps, and their lifecycle. Owns numeric T1
  and T-1 forms, named T-NAME forms, plus PENDING, TODO, and CANCEL. MUST load
  for a recognized declaration or when an uppercase control is used as an
  order. Never persists state outside the current thread.
---

# Tasks

Track explicit work items by identifier for the current thread only. Keep all state ephemeral and never write or persist it to files, memory stores, or external systems.

## Detection

- A canonical declaration at the start of a line or list item is mandatory. Load this skill and track the declaration.
- A new-task declaration at the start of a line or list item is mandatory. Recognize `NEW TASK`, `nouvelle tâche`, `T?`, and `T(new)` when followed by `.`, `:`, or `-` and a description.
- An uppercase `PENDING`, `TODO`, or `CANCEL` used as an order is mandatory. Load this skill and apply it.
- A lowercase or mixed-case control may trigger this skill only when it is clearly an order, such as a standalone instruction or an attached suffix.
- A control or identifier mentioned in ordinary prose is not an order or a new declaration.

## Syntax

- This skill exclusively owns numeric `T<number>` forms and the `T-` prefix.
- A declaration starts a line or list item with a recognized identifier, followed immediately by `.` or `:`, then its description.
- A new-task declaration allocates the next unused numeric identifier. The accepted prefixes are case-insensitive `NEW TASK` and `nouvelle tâche`, plus exact `T?` and case-insensitive `T(new)`. Replace the prefix with the allocated identifier in all responses; never keep it as the task's display identifier.
- Derive a concise task name from each new-task description, usually two to five words. For canonical declarations, preserve a concise description as the name or condense a long request. Keep the complete request as the task's scope; the short name is only a display label.
- Use `T1`, `T2`, and so on for numeric work. This is the recommended form.
- Accept `T-1`, `T-2`, and equivalent hyphenated numeric forms as aliases. `T1` and `T-1` always resolve to the same item.
- Use a dotted numeric suffix for a reply or discussion point: `T1.1`, `T1.2`, and so on. `T-1.1` is an alias. A discussion point is not separately tracked unless the user explicitly declares it as one.
- Append an uppercase letter for a direct tracked subtask with its own lifecycle: `T1A`, `T1B`, and so on. `T-1A` and `T-1B` are aliases.
- Append `-S<number>` for an ordered step inside a task: `T1-S1`, `T1-S2`, and so on. `T-1-S1` and `T-1-S2` are aliases.
- Uppercase names use the hyphenated form, including `T-AUTH` and `T-AUTH-API`. Do not accept compressed names such as `TAUTH`.
- For equivalent numeric aliases, preserve the spelling used by the first declaration as the display form. Later aliases refer to that same item and never create another item.
- An identifier inside a sentence is a reference, not a declaration.
- Match the longest recognized identifier before treating `.` as the declaration delimiter.
  `T1.1: Description` explicitly declares a tracked discussion item; a bare `T1.1`
  reference does not.
- A subtask or step requires its parent task to exist. If `T1A` or `T1-S1` is declared
  before `T1`, ask for the missing parent task and do not create an implicit one.
- Preserve user-defined IDs except for numeric alias resolution. Never renumber or reuse an item in the current thread.
- Ask for clarification only when the distinction changes scope, permission, or execution.

Examples:

```text
T1. Explain the failure - ANSWER
T2: Update the parser - GO
NEW TASK: Compare header sizes - ANSWER
T? - Add the mobile breakpoint - GO
T(new) - Document the chosen size
T2A. Add the regression test - GO
T2-S1: Update the parser grammar
T2-S2: Verify existing syntax remains compatible
T-AUTH: Review the authentication flow - REVIEW
```

An execution directive can be attached to a declaration through punctuation or a common separator. The directives skill defines its effect; this skill supplies the declaration boundary and scoped identifier.

## Lifecycle

- Identify all declarations before handling them.
- Track each declared item as pending, in progress, completed, blocked, or canceled while it remains relevant in the current thread.
- Refer to items by ID when reporting progress, completion, blockers, dependencies, or a shared cause.
- When answering a task handled with `ANSWER`, identify it as `<ID> - <short name>` and include a very condensed version of the question beside it, for example `T4 - Header Size - Q: mobile size?`.
- After a long exchange or when many tasks are visible, restore context by starting a task-specific update with `<ID> - <short name>:`, for example `T4 - Header Size: updated to 64px.` Do not repeat the label on every short adjacent reply when the task is already unambiguous.
- Handle items independently. A blocked item does not prevent work on another item unless they depend on each other.
- Mark an item in progress when work starts.
- Mark an item completed automatically only after its requested outcome and necessary verification are complete.
- Mark an item blocked when required information, permission, or a dependency prevents progress.
- The agent may declare newly discovered required work with the next unused numeric ID for an independent item or the next unused letter for a direct subtask. State why it was added and leave it pending until the user authorizes it with an execution directive or direct instruction.
- Do not create entries for routine implementation steps.
- Do not create follow-up entries automatically after an answer or opinion.

## Subtasks And Steps

A subtask is an independently trackable child outcome. A step is an ordered part of its parent's execution:

- `T1A` has its own lifecycle and may run independently or in parallel with other subtasks.
- `T1-S1` belongs to the sequence of `T1`. Run steps in numeric order unless the user explicitly reorders or revises the sequence.
- A step may be referenced and targeted directly. Do not start it while a required earlier step remains incomplete.
- Track step state as part of the parent. If the current step is blocked, report the parent as blocked by that step.
- Completing a step advances the parent but does not complete it unless its requested outcome and all required work are complete.
- `TODO` shows the current step under its parent instead of presenting every step as an independent top-level item.
- A control attached to a step applies only to that step. Canceling a required step blocks later steps until the user explicitly revises the sequence; do not infer that cancellation means the step may be skipped.
- Create steps only when explicit sequence improves execution or when the user declares them. Do not expand routine work into steps by default.

## Controls

### PENDING

Leave the scoped item pending. Do not inspect, answer, execute, or mutate for it until the user gives another control, an execution directive, or a direct instruction.

### TODO

List all known items in the current thread that are not completed or canceled. Include pending, in-progress, and blocked items without executing or mutating them. Format each item as:

```text
T1 - Short task name - PENDING
A compact description of the task's current scope.
Use no more than three description lines.
```

Use the uppercase status `PENDING`, `IN PROGRESS`, or `BLOCKED`. Keep the title on one line, followed by at most three lines that summarize the current scope, current step, or blocker. Do not include task history, completed details, or unrelated commentary. If no items remain, say so.

### CANCEL

Mark the scoped item canceled and do not inspect, answer, execute, or mutate for it. Cancellation is final for that identifier; preserve the identifier and do not reuse it.

## Scope

- A control appended to a canonical declaration or paired with an identifier reference applies only to that item.
- A standalone `TODO` applies to all known items in the current thread.
- A local task control overrides a message-wide execution directive for that item.
- `CANCEL` is final for its item and overrides every execution directive in the same request.
- `PENDING` blocks message-wide execution. A later execution directive explicitly attached
  to the same item releases it from pending; otherwise it remains pending.
- If the scope of `PENDING` or `CANCEL` is ambiguous, ask one short question and do not act on any possible target.
- The last control replaces earlier controls only within the same scope.
