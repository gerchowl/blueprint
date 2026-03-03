---
name: debug-state
description: Debug state registry issues in Blueprint. Use when encountering "can only be used when context is known" errors or other state-related problems.
allowed-tools: Read, Grep, Glob, Bash(typst *)
---

Debug state management issues in the Blueprint package.

The most common issue is that `state().get()` requires Typst `context` expressions. This affects `place-component()`, `component-extend()`, `get-connector()`, and `resolve-connector-reference()`.

## Diagnosis Steps

1. Search for the error message in the output to identify the failing function.
2. Grep for `state().get()` and `.get()` calls in `src/`:
   ```
   Grep for: \.get\(\) in src/**/*.typ
   ```
3. Check if the call site is wrapped in a `context` expression.
4. Identify whether the issue is in:
   - `component-registry.get()` — used in `place-component`, `component-extend`, `render`
   - `connector-registry.get()` — used in grouped connector resolution
   - `edge-style-registry.get()` — used in `get-edge-style`
   - `canvas-registry.get()` — used in coordinate transforms
   - `object-registry.get()` — used in relative positioning

## State Registries

```
state("component-registry", (:))    — component.typ
state("canvas-registry", (:))       — canvas.typ
state("connector-registry", (:))    — connector.typ
state("edge-style-registry", (:))   — edge.typ
state("style-registry", (:))        — style.typ
state("object-registry", (:))       — layout.typ
```

## Common Fixes

- Wrap `state().get()` calls in `context { ... }` blocks
- Use `state().display(d => ...)` instead of `.get()` where possible
- Restructure to pass data via function arguments instead of registry lookups
- For tests: stick to primitive-only tests that avoid `place-component()`

## Relevant Files

Read these to understand the state flow:
- `src/component.typ` (lines with `.get()`)
- `src/connector.typ` (get-connector function)
- `src/edge.typ` (resolve-connector-reference)
- `src/canvas.typ` (get-absolute-position)
- `tests/_component-tests-disabled/` (examples of what doesn't work)
