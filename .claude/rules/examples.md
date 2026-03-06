---
paths:
  - "examples/**/*.typ"
---

# Example File Conventions

- Import from lib.typ: `#import "../src/lib.typ" as blueprint`
- Import CeTZ separately if needed: `#import "@preview/cetz:0.4.2": *`
- Set explicit page dimensions: `#set page(width: Xcm, height: Ycm, margin: 1cm)`
- Include a heading and brief description of what the example demonstrates
- Keep examples simple and focused on one concept
