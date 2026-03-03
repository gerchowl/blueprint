---
name: build
description: Run the full Blueprint build pipeline (check, test, docs). Use after significant changes to verify everything works.
disable-model-invocation: true
allowed-tools: Bash(just *), Bash(typst *), Bash(./bin/tt *), Read
---

Run the full Blueprint build pipeline.

## Steps

1. Run `just check` to verify the package structure and that `src/lib.typ` compiles.
2. Run `just test` to execute all visual regression tests.
3. Run `just docs` to compile the API documentation.
4. Report the status of each step. If any step fails, diagnose the issue before continuing.

The full pipeline can also be run with `just build`, which chains check + test + docs.
