---
name: add-primitive
description: Scaffold a new primitive type in Blueprint following the unified model pattern.
argument-hint: "<shape-name>"
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Bash(just test*)
---

Add a new primitive type called `$ARGUMENTS` to the Blueprint package.

Primitives follow the unified model — they are "minimal components" created via `create-minimal-component()`.

## Steps

1. Read `src/primitives.typ` to understand the existing pattern (rect, circle, ellipse).
2. Add a new `primitive-$ARGUMENTS()` function following this structure:
   - Accept shape-specific parameters (position, size, fill, stroke, etc.)
   - Create the CeTZ draw shape using `cetz.draw.*`
   - Define `bounds` as `(x:, y:, width:, height:)`
   - Define `anchors` dictionary with named anchor points
   - Define `get-anchor` function using `anchor-to-offset()`
   - Return `create-minimal-component(bounds, shape, anchors, get-anchor)`
3. Add the new type to the `primitive()` generic wrapper function.
4. Update `src/lib.typ` if a new import is needed (usually not, since `primitives.typ` is already imported).
5. Create a test at `tests/primitives-$ARGUMENTS/test.typ` following test conventions.
6. Run `just test-single primitives-$ARGUMENTS` to verify.

## Pattern Reference

```typst
#let primitive-$ARGUMENTS(...params) = {
  let shape = cetz.draw.<shape-fn>(...)
  let bounds = (x: ..., y: ..., width: ..., height: ...)
  let anchors = ("center": (...), "top": (...), ...)
  let get-anchor = (anchor-name) => {
    let (h-offset, v-offset) = anchor-to-offset(anchor-name)
    // Calculate position from offsets
  }
  create-minimal-component(bounds, shape, anchors, get-anchor)
}
```
