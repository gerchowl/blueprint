# Blueprint Test Suite

This directory contains comprehensive visual regression tests for Blueprint.

## Test Structure (DRY & SOLID)

Each test file focuses on a specific feature:

### Primitive Tests
- `primitives-rect/` - Rectangle primitives with various styles (colors, radius, stroke)
- `primitives-circle/` - Circle primitives with various styles
- `primitives-ellipse/` - Ellipse primitives with various styles

### Color Tests
- `color-variations/` - Color palettes and transparency tests

### Component Tests
- `component-borders-rect/` - Components with rectangular borders (including rounded corners)
- `component-borders-circle/` - Components with circular borders
- `component-borders-ellipse/` - Components with elliptical borders
- `nested-components/` - Components containing multiple primitives

### Feature Tests
- `component-connectors/` - Individual, grouped, and custom-styled connectors
- `component-inheritance/` - Component extension via `component-extend()`
- `edge-routing/` - Edge routing modes (direct, rectangular, manhattan) and arrow marks
- `render-modes/` - Detailed, collapsed, and high-level rendering modes
- `styles-and-themes/` - Style creation, inheritance, and edge styles

### Legacy (`_component-tests-disabled/`)
Original test versions that used the old state-based API. Kept for reference only.

## DRY Principles

Each test file uses:
1. **Test parameters** - Arrays of test cases to avoid repetition
2. **Helper functions** - Reusable component/primitive creators
3. **Loops** - Iterate through test cases instead of copy-paste

Example:
```typst
#let test-cases = ((0cm, red, 2pt), (3cm, blue, 1pt), ...)
#for (x, color, stroke) in test-cases {
  let rect = primitive-rect((x, 0pt), (2cm, 1cm), fill: color.lighten(80%), stroke: stroke + color)
  blueprint.render(rect)
}
```

## SOLID Principles

### Single Responsibility
Each test file tests ONE specific feature

### Open/Closed
Tests are open for extension (add new test cases to arrays), closed for modification

### Liskov Substitution
Primitives and components can be used interchangeably (unified model)

### Interface Segregation
Tests only import what they need from exports.typ

### Dependency Inversion
Tests depend on abstractions (blueprint API) not implementations

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

**Active Tests (13):**
- primitives-rect — Rectangle primitives with radius, colors, strokes
- primitives-circle — Circle primitives with various colors and sizes
- primitives-ellipse — Ellipse primitives with various radii
- color-variations — Color palettes and transparency
- component-borders-rect — Components with rectangular borders
- component-borders-circle — Components with circular borders
- component-borders-ellipse — Components with elliptical borders
- nested-components — Components containing multiple primitives
- component-connectors — Individual and grouped connectors, custom styles
- component-inheritance — Component extension and inheritance chains
- edge-routing — Direct, rectangular, manhattan routing with arrow marks
- render-modes — Detailed, collapsed, high-level rendering
- styles-and-themes — Style creation, inheritance, edge styles

**Not Yet Implemented:**
- Relative positioning tests
- Complex multi-component diagrams with edges between components
