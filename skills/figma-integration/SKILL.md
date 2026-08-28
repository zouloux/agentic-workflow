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

Record the Figma node IDs returned by the MCP in exactly one place during integration. Prefer the
style file (CSS Modules, SCSS, CSS, Less, or equivalent). If no style file exists, put the comment
in the TSX or JSX component instead. Never duplicate it across style and component files. Do not
require or reconstruct a full Figma URL when the MCP does not provide one:

```scss
// Figma-Integration:
// - Base: <parent-node-id>
.component {
}
```

- Record one parent node ID by default.
- Add child, theme, breakpoint, or state nodes only when they are materially useful for
  understanding the implemented styles. Otherwise omit them.
- In a style file, place the `Figma-Integration` source immediately above the selector it explains.
- With CSS-in-JS, use one `Figma-Integration` comment at the top of the component and list only the
  useful nodes.
- Do not add comments to HTML, TSX, JSX, SCSS, CSS, Less, or other integration code by default.
  Allow only `TODO`, `FIXME`, `Figma-Integration`, and `Magic-number` comments. Use `Magic-number`
  to explain why a non-obvious numeric value is necessary, with a terse reason:

  ```scss
  // Magic-number: Visual adapted position to correct the missing text-cap.
  margin-top: 2rem;
  ```

  Add another terse explanation only when the code would be genuinely difficult to understand
  without it.
- Do not copy a visual analysis into comments or store Figma node inventories in contexts.
- A mission may keep additional node references while they are needed for active work.
