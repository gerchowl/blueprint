# CLAUDE.md

## Project Overview

Blueprint is a **Typst package** for creating hierarchical technical component diagrams with nested components. It is built on [CeTZ](https://github.com/cetz-package/cetz) (v0.4.2) and provides multi-level rendering of component diagrams (detailed, collapsed, high-level views).

- **Language:** Typst (markup/scripting language for typesetting)
- **Version:** 0.1.0 (in development)
- **Package entrypoint:** `src/lib.typ`
- **Package manifest:** `typst.toml`

## Repository Structure

```
├── src/                    # Source code (Typst)
│   ├── lib.typ             # Main entrypoint, re-exports all modules
│   ├── deps.typ            # Centralized dependency imports (CeTZ)
│   ├── exports.typ         # Testing entrypoint (re-exports + cetz)
│   ├── component.typ       # Component system (creation, placement, rendering)
│   ├── connector.typ       # Connector definitions and rendering
│   ├── edge.typ            # Edge routing and connection logic
│   ├── canvas.typ          # Nested canvas/coordinate transformation system
│   ├── layout.typ          # Positioning (absolute/relative) and bounds
│   ├── primitives.typ      # Drawing primitives (rect, circle, ellipse)
│   ├── style.typ           # Style system with inheritance and themes
│   └── utils.typ           # Helper functions (vector math, anchors)
├── tests/                  # Visual regression tests (Tytanic)
│   ├── primitives-rect/    # Rectangle primitive tests
│   ├── primitives-circle/  # Circle primitive tests
│   ├── primitives-ellipse/ # Ellipse primitive tests
│   ├── color-variations/   # Color and transparency tests
│   ├── component-borders-*/ # Component border shape tests
│   ├── nested-components/  # Nested component tests
│   └── _component-tests-disabled/  # Tests blocked by state management issue
├── examples/               # Example Typst files
│   └── simple.typ          # Basic component example
├── docs/
│   └── manual.typ          # API reference (generated via Tidy)
├── Cargo.toml              # Dev tools only (Tytanic version pin)
├── typst.toml              # Typst package manifest
├── justfile                # Task runner commands
├── PRD.md                  # Product Requirements Document
└── README.md               # User-facing documentation
```

## Development Commands

This project uses [Just](https://github.com/casey/just) as a task runner.

```bash
just install         # Install dev dependencies (Tytanic test runner)
just test            # Run all tests (requires bin/tt from install)
just test-single <name>  # Run a specific test (e.g., just test-single primitives-rect)
just test-update     # Update test reference images
just docs            # Compile docs/manual.typ
just docs-watch      # Watch and recompile docs on changes
just examples        # Compile all examples/*.typ
just check           # Verify package structure and compilation
just build           # Full build: check + test + docs
just clean           # Remove generated PDFs/PNGs/SVGs
```

The test runner (Tytanic) is installed locally to `bin/tt`. Run `just install` before running tests.

## Testing

- **Framework:** [Tytanic](https://github.com/tingerrr/tytanic) (visual regression testing for Typst)
- **Test location:** `tests/<test-name>/test.typ`
- **Reference images:** `tests/<test-name>/ref/` (committed to git)
- **Test output:** `tests/<test-name>/out/` and `tests/<test-name>/diff/` (git-ignored)

### Test conventions

- Each test directory contains a single `test.typ` file
- Tests import from `/src/exports.typ` as `blueprint` (not from `lib.typ`)
- Tests use parametrized test cases with loops for DRY code
- Each test file sets explicit page dimensions: `#set page(width: Xcm, height: Ycm, margin: 1cm)`

### Current test status

- **4 passing tests:** primitives-rect, primitives-circle, primitives-ellipse, color-variations
- **Disabled tests** (in `_component-tests-disabled/`): component-borders and nested-components are blocked by a state management issue with `place-component()` — Typst's `state().get()` requires `context` expressions

## Architecture

### Module dependency graph

```
lib.typ → deps.typ (cetz)
        → utils.typ
        → primitives.typ → deps.typ, utils.typ
        → style.typ
        → canvas.typ → deps.typ, utils.typ
        → layout.typ → deps.typ, utils.typ, canvas.typ, style.typ
        → component.typ → deps.typ, utils.typ, canvas.typ, layout.typ, style.typ, connector.typ, primitives.typ
        → connector.typ → deps.typ, utils.typ
        → edge.typ → deps.typ, utils.typ, canvas.typ, connector.typ, primitives.typ, style.typ
```

### Key design patterns

- **Registry pattern:** Global state registries via Typst's `state()` for components, connectors, canvases, styles, edges, and positioned objects
- **Unified model:** Primitives are "minimal components" sharing the same interface as full components (`bounds`, `render()`, `get-anchor()`, `is-primitive`)
- **Factory functions:** `component()`, `connector()`, `edge-style()`, `primitive-rect/circle/ellipse()` create dictionary objects
- **Strategy pattern:** Rendering modes (detailed/collapsed/high-level) and edge routing (direct/rectangular/manhattan/manual)

### State registries

```typst
state("component-registry", (:))    # All defined components
state("canvas-registry", (:))       # Nested coordinate systems
state("connector-registry", (:))    # Grouped connectors
state("edge-style-registry", (:))   # Edge style definitions
state("style-registry", (:))        # Reusable styles
state("object-registry", (:))       # Objects for relative positioning
```

State is updated with `.update(d => { ...; d })` and read with `.get()`. Functions use `return` to avoid joining state update content with return values.

## Code Conventions

### Naming

- **Functions and variables:** `kebab-case` (e.g., `place-component`, `content-bounds`, `edge-style`)
- **Registry names:** `kebab-case` with `-registry` suffix
- **Doc comments:** Triple-slash `///` for public API functions
- **Inline comments:** `//` for implementation notes

### Import pattern

- Source modules use relative imports: `#import "deps.typ": cetz`
- Tests import: `#import "/src/exports.typ" as blueprint`
- Examples import: `#import "../src/lib.typ" as blueprint`
- External packages: `#import "@preview/cetz:0.4.2"`

### Function signatures

Functions use named parameters with defaults:
```typst
#let component(name, content, origin: (center, center), internal-origin: (left, top),
               border: true, border-shape: "rect", margin: 2mm, style: none,
               connectors: (), parent: none) = { ... }
```

### Error handling

Use Typst's `error()` function for invalid arguments:
```typst
if comp == none { error("Component not found: " + str(comp-name)) }
```

Validate lookups with `.at(key, default: none)` then check for `none`.

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| CeTZ | 0.4.2 | Core 2D drawing library |
| Tidy | 0.4.3 | Documentation generation (auto-downloaded) |
| Tytanic | 0.3.1 | Visual regression test runner (dev tool) |

## Known Issues

- `place-component()` uses `state().get()` which requires Typst `context` expressions; this blocks component-level tests
- Arrow marks/decorations in edge rendering are marked as TODO
- `calculate-bounds()` in `utils.typ` is a placeholder returning zero bounds
- No code formatter is configured for Typst files
- No CI/CD pipeline yet

## Build Artifacts (git-ignored)

- `*.pdf`, `*.png`, `*.svg` — compiled output
- `bin/` — local tool binaries (Tytanic)
- `target/` — Cargo build artifacts
- `.typst/` — Typst cache and local packages
- `tests/*/out/`, `tests/*/diff/` — test output (reference images in `ref/` are tracked)
