---
name: afk
description: AFK mode with mobile notifications via iCloud Reminders on macOS. Load when the user says they are AFK or away, or asks the agent to alert them during work.
---

# AFK

Send a simple alert from a macOS agent to the user's iPhone using the built-in Reminders
app and iCloud sync. No third-party service or server is required.

Invocation: `/afk <operation or message>` — e.g. `/afk test` or
`/afk "Codex" "I have a question about deployment."`.

## Explicit activation only

**Never use this skill proactively without an explicit signal from the user.** Valid
signals include:

- `/afk ...`;
- “notify me when you need me” or “ping me when this is done”;
- the user explicitly saying they are AFK, stepping away, or leaving for a while while
  the agent continues working.

Do not infer that the user is AFK because they are silent, because a task is long, or
because a notification would be convenient. Do not turn notification mode on globally.

Keep the user's requested scope:

- “notify me when done” permits a completion notification only;
- “I'm AFK, notify me if you need me” permits question/blocker notifications for the
  current task;
- “notify me after the migration” permits one notification at that exact checkpoint;
- a duration or broader scope applies only when the user states it explicitly.

An AFK/away instruction ends when the user returns with a new message, when the current
task ends, or when its explicit duration expires.

## Requirements

- macOS with the Reminders app.
- Reminders enabled in iCloud on the Mac and iPhone, using the same Apple Account.
- The default Reminders account on the Mac must be iCloud.
- Reminders notifications must be allowed on the iPhone. Focus modes can still silence
  them.

The first run can trigger a macOS Automation permission prompt. Tell the user to allow
the terminal or agent application to control Reminders; never work around a denial.

## Operations

| Operation | What to do |
|---|---|
| **test** | Run `AGENT_NOTIFY_DELAY=1 scripts/agent-notify "AFK" "This is a test."`. Tell the user to expect the alert immediately. |
| **send** | Run `scripts/agent-notify "<agent>" "<simple message>"`. |
| **when done** | Treat this as a current-task obligation. Continue the task, then send one simple completion notification. Do not notify after intermediate turns. |

The command is bundled with the skill. Always run `scripts/agent-notify` directly (with
`zsh` if direct execution is unavailable). No installation step or global command is
required.

## Blocking questions: notify first

When notification mode is active **for questions or attention**, and the agent needs to
ask the user something:

1. Reduce the topic to a few plain words.
2. Run `scripts/agent-notify` and wait for it to succeed.
3. Only then ask the question in the terminal or call a blocking question/input tool.

The notification must never be queued after, or in parallel with, the question tool: the
question blocks the agent, so later work may not run. This ordering also applies when the
agent is about to end its turn with a question.

If notification delivery fails, report that failure briefly in the terminal and then ask
the question normally. Do not hide or delay the actual question indefinitely.

## When to notify

Within the exact scope authorized by the user, the only default notification boundaries
are:

- a question or approval is needed before work can continue;
- the agent is genuinely blocked;
- the requested work completed.

An unrecoverable error counts as a blocker. Any other event or intermediate checkpoint is
allowed only when the user explicitly named that precise event, for example “notify me
after the migration finishes.” Do not broaden that permission to nearby steps.

Do not notify for routine tool calls, commentary updates, short answers, every agent turn,
progress updates, intermediate milestones, or events outside the user's requested scope.
One state transition produces at most one notification.

## Message format

Keep notifications deliberately plain. Use the agent name as the title and one short
English sentence as the body. Preferred templates:

```text
Codex
I have a question about deployment.

Codex
The task is finished.

Codex
I'm blocked on authentication.
```

For a question, prefer exactly `I have a question about <short topic>.` Keep the topic to
a few non-sensitive words. Put the full question and context in the terminal, not in the
notification.

Never include secrets, tokens, private source excerpts, raw logs, or long model output.
The text may be visible on the lock screen.

## Reminder lifecycle

The command owns only reminders in the `Agents` list whose title starts with `🤖 `.
Before sending, it removes the previous marked reminder and creates the new one. It does
**not** delete the new reminder after delivery; that reminder stays until the next send.
Manually created reminders without the prefix are left untouched.

Defaults can be overridden per invocation:

```bash
AGENT_NOTIFY_LIST="Agents" AGENT_NOTIFY_DELAY=60 scripts/agent-notify "Codex" "I have a question about deployment."
```

The default delay is 60 seconds to give iCloud time to sync the reminder to the iPhone.
