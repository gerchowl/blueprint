---
paths:
  - "src/**/*.typ"
---

# Typst Source Conventions

## Module Structure

- Each module starts with a `///` doc comment describing its purpose
- Import dependencies from `deps.typ`: `#import "deps.typ": cetz`
- Import sibling modules with relative paths: `#import "utils.typ": *`
- Public API functions use `///` doc comments; internal notes use `//`

## Naming

- Functions and variables: `kebab-case` (e.g., `place-component`, `edge-style`)
- Registry state names: `kebab-case` with `-registry` suffix (e.g., `component-registry`)
- Named parameters with defaults for all optional arguments

## State Management

- Registries use `state("name-registry", (:))` with dictionary values
- Update state with `.update(d => { ...; d })` — always return the dictionary
- Read state with `.get()` — requires `context` expression in Typst
- Use `return` to avoid joining state update content with function return values

## Error Handling

- Use `error("descriptive message")` for invalid arguments
- Validate dictionary lookups: `.at(key, default: none)` then check for `none`

## Primitives

- Primitives are "minimal components" created via `create-minimal-component()`
- Must include: `bounds`, `shape`, `anchors`, `get-anchor`, `is-primitive: true`
- Rendering uses CeTZ draw functions: `cetz.draw.rect()`, `cetz.draw.circle()`, etc.
