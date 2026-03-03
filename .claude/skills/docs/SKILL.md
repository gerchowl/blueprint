---
name: docs
description: Compile the Blueprint API documentation from docs/manual.typ using Tidy.
allowed-tools: Bash(typst *), Bash(just docs*), Read
---

Compile the Blueprint API documentation.

## Steps

1. Run `just docs` to compile `docs/manual.typ`.
2. If compilation fails, read the error output and diagnose. Common issues:
   - Missing Tidy package: it auto-downloads on first use, ensure network access
   - Source file doc comment syntax errors: check `///` comments in `src/*.typ`
3. Report success or failure with details.

## Watch Mode

For continuous documentation development, use:
```bash
just docs-watch
```
