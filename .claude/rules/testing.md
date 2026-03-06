---
paths:
  - "tests/**/*.typ"
---

# Test Conventions

## Test Structure

- Each test lives in `tests/<test-name>/test.typ`
- Reference images are committed in `tests/<test-name>/ref/`
- Test output goes to `tests/<test-name>/out/` and `tests/<test-name>/diff/` (git-ignored)
- Disabled tests go in `tests/_component-tests-disabled/`

## Writing Tests

- Import: `#import "/src/exports.typ" as blueprint` (never `lib.typ`)
- Set explicit page dimensions: `#set page(width: Xcm, height: Ycm, margin: 1cm)`
- Use parametrized test cases with arrays and loops for DRY code
- Each test file tests ONE specific feature (single responsibility)

## Test Patterns

```typst
// Define test parameters as an array of tuples
#let test-cases = (
  (0cm, red, 2pt),
  (3cm, blue, 1pt),
)

// Loop over test cases
#for (x, color, stroke-width) in test-cases {
  let prim = blueprint.primitive-rect(
    (x, 0pt), (2cm, 1cm),
    fill: color.lighten(80%),
    stroke: stroke-width + color,
  )
  blueprint.render(prim)
}
```

## Running Tests

```bash
just test                        # Run all tests
just test-single primitives-rect # Run one test
just test-update                 # Update reference images after visual changes
```

## Known Limitation

Tests using `place-component()` fail because `state().get()` requires `context` expressions. Only primitive-only tests work currently.
