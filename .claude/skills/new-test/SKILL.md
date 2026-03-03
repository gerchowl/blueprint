---
name: new-test
description: Create a new visual regression test for Blueprint. Use when adding test coverage for a feature.
argument-hint: "<test-name>"
disable-model-invocation: true
allowed-tools: Bash(mkdir *), Write, Read, Bash(just test*)
---

Create a new Tytanic visual regression test.

## Steps

1. Create the test directory: `mkdir -p tests/$ARGUMENTS`
2. Create `tests/$ARGUMENTS/test.typ` following the test conventions:
   - Import: `#import "/src/exports.typ" as blueprint`
   - Set page dimensions: `#set page(width: Xcm, height: Ycm, margin: 1cm)`
   - Use parametrized test cases with arrays and loops
   - Test ONE specific feature
3. Run the test: `just test-single $ARGUMENTS`
4. If the test passes visually, generate reference images: `just test-update`
5. Verify the reference images were created in `tests/$ARGUMENTS/ref/`

## Template

```typst
/// Test: <description>
#import "/src/exports.typ" as blueprint

#set page(width: 12cm, height: 8cm, margin: 1cm)

#let test-cases = (
  // (param1, param2, ...),
)

#for (params) in test-cases {
  // Create and render test subjects
}
```
