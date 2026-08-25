---
name: figma-integration
description: >
  Figma MCP workflow for inspecting, implementing, tracing, and verifying designs. Use when the
  user supplies or selects a Figma node, asks to implement or compare a Figma design, or when Figma
  MCP access is required. Do not load for incidental mentions of Figma.
---

# Figma Integration

Before using the Figma MCP, load the harness's Figma design-to-code guidance when available.

## Source resolution

Resolve the design source in this order:

1. A Figma URL or node supplied explicitly by the user.
2. The current Figma selection, after confirming its name, screenshot, and design context match the
   requested element.
3. A canonical node reference present in project contexts already loaded for the task.

If none is valid, **HALT** and ask the user to select the exact element in Figma. Do the same when
the selection is missing, unrelated, ambiguous, or too broad for the requested work. Do not search
the wider Figma file, substitute a nearby node, infer unseen design details, or begin implementation
from an unverified selection.

## Workflow

1. Read the design context, variables, and screenshot through the Figma MCP. A screenshot alone is
   not sufficient.
2. Inspect the target project's existing components, tokens, and conventions before implementing.
3. Map the design to existing project primitives. Do not invent missing styles, assets,
   interactions, or responsive behavior; report material gaps.
4. Verify the result against the relevant Figma variants and report intentional deviations.

## Source comments

Record the Figma node IDs returned by the MCP in the style file during integration. Do not require
or reconstruct a full Figma URL when the MCP does not provide one:

```scss
// Figma:
// - Base: <parent-node-id>
.component {
}
```

- Record one parent node ID by default.
- Add child, theme, breakpoint, or state nodes only when they are materially useful for
  understanding the implemented styles. Otherwise omit them.
- In SCSS, Less, or CSS, place a source immediately above the selector it explains.
- With CSS-in-JS, use one Figma comment at the top of the component and list only the useful nodes.
- Do not copy a visual analysis into comments or store Figma node inventories in contexts.
- A mission may keep additional node references while they are needed for active work.
