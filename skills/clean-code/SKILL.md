---
name: clean-code
description: >
  Opinionated coding conventions for comments, React component structure, CSS Modules, and BEM.
  Use when writing, editing, or reviewing code in a matching stack.
---

# Clean Code

Apply only the sections that match the current language and stack. React, CSS Modules, and BEM are
independent; never introduce one only to satisfy a rule for another. Explicit user requirements and
established project conventions take priority when they conflict with this skill.

## Coding style

### Comments

Never add a code comment unless the user explicitly requests it or the code would be genuinely
difficult to understand without an explanation of its non-obvious intent or constraints. Never
comment what the code already makes clear.

After editing, review every comment added during the task. If a comment is unnecessary, remove it
with a separate edit operation.

#### Markers

These markers are allowed when they communicate concrete, useful information:

```text
// NOTE: Important context that must be preserved.
// TODO: Work that remains incomplete.
// FIXME: A known issue that requires correction.
```

- Use the exact uppercase `NOTE:`, `TODO:`, or `FIXME:` prefix.
- Keep the text short and actionable. Do not restate the code.
- Do not invent a `TODO` or `FIXME` without a real pending task or known issue.
- Honor additional comment markers defined by an active specialized skill.

#### Section separators

Use separators only when they materially improve navigation in a substantial file.

For a main section, use an uppercase title and pad with hyphens so the title starts at column 81 after the space:

```text
// ----------------------------------------------------------------------------- DASHBOARD
```

If you detect a gutter column at another position than 80, align.

Do not close the title with trailing hyphens. For a subsection, use a short title without column
alignment:

```text
// --- Login

// --- Lost my password
```

## React

Apply this section only to React code.

### Props and component shape

Declare component props with an `interface Props`. Receive `props: Props`, then destructure the
needed fields inside the function body:

```tsx
interface Props {
  className?: string
}

export function MyComponent(props: Props) {
  const { className } = props

  return <div className={cn(S.root, className)}>...</div>
}
```

Do not destructure props in the function parameter. A visual component must own a DOM root rather
than return another React component as its sole root. Use the appropriate semantic HTML element;
use `div` when no more specific element is appropriate.

When the component uses a CSS Module, apply its root class, root modifiers, and incoming
`className` to that DOM root. Use the project's class-name utility; the examples use `cn`.

### List rendering

When a `.map()` callback contains more than about four significant lines of JSX, meaningful
nesting, or branching that hides the parent component's structure, prefer a named `renderX`
function. Keep a short callback inline when extraction would make the code harder to follow.

```tsx
type RenderedItem = NonNullable<typeof items>[number]

function renderItem(item: RenderedItem) {
  return <div key={item.id}>...</div>
}

return <>{items?.map(renderItem)}</>
```

- Keep a stable key from the item. Never introduce `key={index}` merely because the callback moved.
- Include the index argument only when the rendering genuinely needs it.
- Derive the item type with `NonNullable<typeof items>[number]` when no clear named type is readily
  available.
- Extract a React component instead when the rendered item owns behavior or state, or is reused.

## Styling

Apply each subsection only when the project uses that styling approach.

### CSS Modules

Every component CSS Module must define `.root`. Bind it to the visual component's DOM root together
with root modifiers and the incoming `className`:

```tsx
return (
  <div
    className={cn(
      S.root,
      disabled && S.root_disabled,
      size && S[`root_size_${size}`],
      className,
    )}
  >
    ...
  </div>
)
```

You can extract `className` as a const if it helps JSX readability or we have too much ternaries and modifiers.

```tsx
const className = cn(S.root, ...)
```

### BEM

Use `.root` as the block class, `.root_modifier` for block modifiers, `.element` for elements, and
`.element_modifier` for element modifiers. SCSS nesting is also valid:

```scss
.root {
  &_size_small {
    .label {
      font-size: 12px;
    }
  }
}

.element {
  &_selected {
  }
}
```

Put a modifier on `.root` when it describes the component's state or variant, even if only one
descendant changes visually. Style affected descendants from that root modifier. Do not repeat the
same modifier on every affected element.

Put a modifier directly on an element only when the variation belongs to that element and can vary
independently from the component.

- For a multi-value prop, include the prop name and value: `root_size_small`, `root_tone_danger`.
- For an unambiguous boolean state, use the state directly: `root_visible`, `root_disabled`.
- Add an axis to a boolean modifier only when its unprefixed name would be ambiguous or collide.
- In React, apply boolean modifiers directly, such as `disabled && S.root_disabled`.
- For typed string unions, use the property axis, such as ``S[`root_size_${size}`]``.
