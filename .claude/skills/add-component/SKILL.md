---
name: add-component
description: Create a new reusable component definition in Blueprint with connectors and styling.
argument-hint: "<component-name>"
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Bash(just *)
---

Create a new component called `$ARGUMENTS` in an example or the user's specified location.

## Steps

1. Read `src/component.typ` and `src/connector.typ` to understand the API.
2. Design the component with:
   - A descriptive `name` parameter
   - `content` array of primitives (rect, circle, ellipse) that form the visual
   - `connectors` array of interface points
   - Appropriate `border-shape` ("rect", "circle", or "ellipse")
   - `margin`, `style`, `origin` as needed
3. Write the component definition.
4. If placing the component, remember that `place-component()` requires a `context` expression (known limitation).

## Component Template

```typst
#let $ARGUMENTS = blueprint.component(
  name: "$ARGUMENTS",
  content: (
    blueprint.primitive-rect((0pt, 0pt), (3cm, 2cm),
      fill: gray.lighten(80%),
      stroke: 1pt + black,
    ),
  ),
  connectors: (
    blueprint.connector("input", (0pt, 1cm)),
    blueprint.connector("output", (3cm, 1cm)),
  ),
  border: true,
  border-shape: "rect",
  margin: 2mm,
)
```

## Known Limitation

`place-component()` uses `state().get()` which requires `context` expressions. Components that only use primitives and `render()` work without this issue.
