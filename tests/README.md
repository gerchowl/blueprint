# Blueprint Test Suite

This directory contains comprehensive tests for the unified model where primitives are minimal components.

## Test Structure (DRY & SOLID)

Each test file focuses on a specific feature:

### Primitive Tests
- `primitives-rect/` - Rectangle primitives with various styles (colors, radius, stroke)
- `primitives-circle/` - Circle primitives with various styles
- `primitives-ellipse/` - Ellipse primitives with various styles

### Color Tests
- `color-variations/` - Color palettes and transparency tests

### Disabled Tests (`_component-tests-disabled/`)
These tests use `place-component()` which requires `context` expressions. They match the current API and should be re-enabled once the `state().get()` issue is resolved.
- `component-borders-rect/` - Components with rectangular borders (including rounded corners)
- `component-borders-circle/` - Components with circular borders
- `component-borders-ellipse/` - Components with elliptical borders
- `nested-components/` - Components containing multiple primitives

## DRY Principles

Each test file uses:
1. **Test parameters** - Arrays of test cases to avoid repetition
2. **Helper functions** - Reusable component/primitive creators
3. **Loops** - Iterate through test cases instead of copy-paste

Example:
```typst
// Instead of:
#let rect1 = primitive-rect((0cm, 0pt), (2cm, 1cm), fill: red.lighten(80%), stroke: 2pt + red)
#let rect2 = primitive-rect((3cm, 0pt), (2cm, 1cm), fill: blue.lighten(80%), stroke: 1pt + blue)
// ... many more

// We use:
#let test-cases = ((0cm, red, 2pt), (3cm, blue, 1pt), ...)
#for (x, color, stroke) in test-cases {
  let rect = primitive-rect((x, 0pt), (2cm, 1cm), fill: color.lighten(80%), stroke: stroke + color)
  blueprint.render(rect)
}
```

## SOLID Principles

### Single Responsibility
Each test file tests ONE specific feature

###Open/Closed
Tests are open for extension (add new test cases to arrays), closed for modification (don't change test structure)

### Liskov Substitution
Primitives and components can be used interchangeably (unified model)

### Interface Segregation
Tests only import what they need from exports.typ

### Dependency Inversion
Tests depend on abstractions (blueprint API) not implementations

## Known Issue

**State Management**: Tests using `place-component()` currently fail with "can only be used when context is known". This is a pre-existing issue separate from the unified model implementation and needs to be fixed by:
1. Wrapping state access in `context` expressions
2. Or restructuring to use single canvas approach (as discussed)

Tests that only use primitives work perfectly and demonstrate the unified model.

## Running Tests

```bash
# Run all tests
just test

# Run specific test
just test-single primitives-rect

# Update reference images
just test-update
```

## Test Coverage

**Active Tests (4):**
- primitives-rect — Rectangle primitives with radius, colors, strokes
- primitives-circle — Circle primitives with various colors and sizes
- primitives-ellipse — Ellipse primitives with various radii
- color-variations — Color palettes and transparency

Note: Reference images (`ref/` dirs) have not been generated yet. Run `just test-update` to create baselines.

**Disabled Tests (in `_component-tests-disabled/`, blocked by state management):**
- component-borders-rect — Components with rectangular borders
- component-borders-circle — Components with circular borders
- component-borders-ellipse — Components with elliptical borders
- nested-components — Components containing multiple primitives

**Not Yet Implemented:**
- ⏳ Connectors
- ⏳ Edges
- ⏳ Positioning/placement

