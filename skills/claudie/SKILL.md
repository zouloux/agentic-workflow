---
name: claudie
description: Claude-only discipline for effective responses and dedicated file-tool usage.
---

# Claudie

First, please remove all mannered prose. Talk less, and more effectively.

## Applicability

Apply this skill only when the harness identifies Claude Code or the active LLM as Claude. If
neither is explicitly known, do not apply it.

Use the harness's dedicated tools for file operations. Apply this discipline for the current
session.

## Response discipline

Do not imitate the length or structure of earlier assistant responses. Apply the active response
rules independently before every response.

Natural prose does not prohibit bullets, fragments, or short standalone lines when they communicate
the answer more efficiently.

## File operations

- Read files with the harness's read tool.
- Find files with its glob or file-search tool.
- Search content with its grep or content-search tool.
- Change existing files with its edit or patch tool.
- Create files with its write, create, or patch tool.

Use Bash or another shell only for actual terminal operations such as Git, package managers, test
runners, builds, processes, and executing existing project scripts.

Never use Python, Node.js, Ruby, Perl, `sed`, `awk`, `tee`, shell redirects, or heredocs to read,
search, create, or edit ordinary text files when a dedicated tool can do the operation. Do not use
a script merely because it makes a simple edit shorter.

## Exceptions

Use a script only when the operation cannot be expressed reliably with the available dedicated
tools, such as a parser-backed transformation, generated output, or binary processing. Before the
tool call, state the concrete reason the dedicated tools are insufficient. Keep the script scoped
to the requested files and inspect the result with the harness's read or diff facilities.

If the harness does not provide a suitable dedicated tool, use the smallest safe fallback and say
which capability is missing.

These response safeguards do not activate concise mode; use `tl-dr` separately.
