---
name: afk
description: AFK mode with mobile notifications via iCloud Reminders on macOS. Load when the user says they are AFK or away, or asks the agent to alert them during work.
---

# AFK

Notify the user's iPhone from macOS through Reminders and iCloud sync.

## Activation and scope

Use this skill only when the user explicitly invokes `/afk`, says they are away, or
asks for a notification. Never infer AFK status from silence or task duration.

Keep the exact requested scope. A completion request permits one completion alert;
a question or blocker alert requires explicit permission. A named checkpoint permits
one alert at that checkpoint. AFK mode ends when the user returns, the task ends, or
the stated duration expires.

## Send a notification

Run the bundled command directly from this skill directory:

```bash
scripts/agent-notify "<agent>" "<simple message>"
```

Use `zsh scripts/agent-notify ...` only if direct execution is unavailable. The default
delay is 60 seconds. Override it when needed with `AGENT_NOTIFY_DELAY=<seconds>`.

The first run can request permission to control Reminders. Ask the user to allow it;
never work around a denial. The Mac and iPhone must use the same iCloud Reminders
account, and iPhone notifications must be enabled.

## Notification rules

Within the authorized scope, notify only when:

- a question or approval is required to continue;
- the agent is blocked by an unrecoverable error;
- the requested work is complete;
- the user named that exact checkpoint.

Send at most one notification per state transition. Do not notify for progress,
routine tool calls, intermediate turns, or unrequested milestones.

When attention alerts are authorized and a question is required, send the notification
and wait for success before asking the question. Never send it in parallel with or after
a blocking question tool. If sending fails, report the failure briefly and ask normally.

## Message format

Use the agent name as the title and one short English sentence as the body:

```text
Codex
I have a question about deployment.
```

Keep question topics brief and put full context in the terminal. Never include secrets,
tokens, source excerpts, logs, or other sensitive content visible on a lock screen.
