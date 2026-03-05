# CLAUDE.md

## Project Overview

Blueprint is a **Typst package** for creating hierarchical technical component diagrams with nested components. Built on CeTZ (v0.4.2), it provides multi-level rendering (detailed, collapsed, high-level views).

- **Language:** Typst
- **Version:** 0.1.0 (in development)
- **Entrypoint:** `src/lib.typ`
- **Manifest:** `typst.toml`

## Development Commands

Task runner: [Just](https://github.com/casey/just). Run `just install` before first use.

```bash
just test                    # Run all visual regression tests
just test-single <name>      # Run one test (e.g., just test-single primitives-rect)
just test-update             # Update test reference images
just docs                    # Compile docs/manual.typ
just build                   # Full build: check + test + docs
just check                   # Verify package structure compiles
just clean                   # Remove generated PDFs/PNGs/SVGs
```

## Repository Structure

```
src/                         # Source modules (Typst)
  lib.typ                    # Main entrypoint, re-exports all modules
  deps.typ                   # Centralized CeTZ import
  exports.typ                # Test entrypoint (re-exports + cetz)
  component.typ              # Component creation, placement, rendering
  connector.typ              # Connector definitions and rendering
  edge.typ                   # Edge routing and connection logic
  canvas.typ                 # Nested canvas/coordinate transforms
  layout.typ                 # Positioning (absolute/relative) and bounds
  primitives.typ             # Drawing primitives (rect, circle, ellipse)
  style.typ                  # Style system with inheritance and themes
  utils.typ                  # Vector math, anchors, helpers
tests/                       # Visual regression tests (Tytanic)
examples/                    # Example Typst files
docs/manual.typ              # API reference (generated via Tidy)
```

## Architecture

- **Stateless design:** All factory functions are pure — they return plain dictionaries with no side effects
- **Unified model:** Primitives are "minimal components" with the same interface (`bounds`, `render()`, `get-anchor()`, `is-primitive`)
- **Factory functions:** `component()`, `connector()`, `edge-style()`, `primitive-rect/circle/ellipse()` return dictionary objects
- **Pure placement:** `place-component(comp, position)` returns an updated component dict (no state mutation)
- **Two-layer rendering:** `draw-content(comp)` / `draw-item(item)` produce raw CeTZ draw commands (safe for recursive nesting); `render(comp, mode:)` wraps in `cetz.canvas()` for final output
- **Rendering modes:** `"detailed"`, `"collapsed"`, `"high-level"`

## Key Conventions

- **Naming:** `kebab-case` for everything (functions, variables)
- **Doc comments:** `///` for public API, `//` for implementation notes
- **Imports in source:** `#import "deps.typ": cetz` (relative)
- **Imports in tests:** `#import "/src/exports.typ" as blueprint`
- **Imports in examples:** `#import "../src/lib.typ" as blueprint`
- **Error handling:** `panic()` for invalid args; validate with `.at(key, default: none)` then check `none`
- **No global state:** Functions do not use `state()` registries — all data flows through function arguments and return values

## Testing

- **Framework:** Tytanic (visual regression, installed to `bin/tt`)
- **Test location:** `tests/<name>/test.typ` with reference images in `tests/<name>/ref/`
- **17 active tests:** All passing with reference images
  - **Primitives:** primitives-rect, primitives-circle, primitives-ellipse
  - **Colors:** color-variations
  - **Components:** component-borders-rect, component-borders-circle, component-borders-ellipse, nested-components
  - **Features:** component-connectors, component-inheritance, edge-routing, render-modes, styles-and-themes, relative-positioning
  - **Domain:** computer-architecture, datacenter-architecture (nested components with edges in single canvas)
  - **SQL-driven:** sql-generated (diagram generated from SQLite database via `tools/sql_to_blueprint.py`)
- **Legacy disabled tests** (in `_component-tests-disabled/`): Original versions that used the old state-based API. Kept for reference only.

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| CeTZ    | 0.4.2   | Core 2D drawing library |
| Tidy    | 0.4.3   | Documentation generation |
| Tytanic | 0.3.1   | Visual regression test runner |

## Known Issues

- No code formatter or CI/CD pipeline configured
- Canvas parent-chain walk (`get-absolute-position`) has no cycle detection

## Build Artifacts (git-ignored)

`*.pdf`, `*.png`, `*.svg`, `bin/`, `target/`, `.typst/`, `tests/*/out/`, `tests/*/diff/`

## Additional References

- @PRD.md
- @tests/README.md
