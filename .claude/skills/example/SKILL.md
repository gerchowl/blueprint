---
name: example
description: Create a new Blueprint example file demonstrating a specific feature or use case.
argument-hint: "<example-name>"
disable-model-invocation: true
allowed-tools: Write, Read, Bash(typst compile *)
---

Create a new example file at `examples/$ARGUMENTS.typ`.

## Steps

1. Read `examples/simple.typ` to see the existing example pattern.
2. Create `examples/$ARGUMENTS.typ` with:
   - Import: `#import "../src/lib.typ" as blueprint`
   - Import CeTZ if needed: `#import "@preview/cetz:0.4.2": *`
   - Set page dimensions: `#set page(width: 15cm, height: 10cm, margin: 1cm)`
   - A heading and brief description
   - The example code demonstrating the feature
3. Compile: `typst compile examples/$ARGUMENTS.typ`
4. Verify it compiles without errors.

## Template

```typst
/// Example: <description>
#import "../src/lib.typ" as blueprint
#import "@preview/cetz:0.4.2": *

#set page(width: 15cm, height: 10cm, margin: 1cm)

= <Title> Example

<Brief description of what this example demonstrates.>

// Example code here
```
