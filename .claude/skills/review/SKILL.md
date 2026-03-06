---
name: review
description: Review Typst source code for Blueprint conventions, patterns, and potential issues.
context: fork
agent: typst-explorer
---

Review the recently changed files in this repository for:

1. **Convention compliance:**
   - `kebab-case` naming for functions and variables
   - `///` doc comments on public API functions
   - Relative imports in source (`#import "deps.typ": cetz`)
   - Correct import patterns in tests (`/src/exports.typ`) vs examples (`../src/lib.typ`)

2. **State management:**
   - `.update(d => { ...; d })` pattern returns the dictionary
   - `return` used to avoid joining state update content with return values
   - `.get()` calls are noted as requiring `context` expressions

3. **Unified model compliance:**
   - Primitives use `create-minimal-component()` and set `is-primitive: true`
   - Components and primitives share the same interface (`bounds`, `render()`, `get-anchor()`)

4. **Error handling:**
   - `error()` used for invalid arguments
   - `.at(key, default: none)` followed by `none` check for lookups

5. **Test patterns:**
   - DRY parametrized test cases with arrays and loops
   - Explicit page dimensions set
   - Single feature per test file

Report findings with specific file paths and line numbers. Group by severity: issues, warnings, suggestions.
