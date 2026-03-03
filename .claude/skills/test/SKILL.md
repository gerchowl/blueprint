---
name: test
description: Run the Blueprint visual regression test suite using Tytanic. Use when you need to verify changes haven't broken rendering.
argument-hint: "[test-name]"
allowed-tools: Bash(just *), Bash(./bin/tt *), Read, Glob, Grep
---

Run the Blueprint test suite. If a test name argument is provided, run only that test. Otherwise run all tests.

## Steps

1. Check that `bin/tt` exists. If not, tell the user to run `just install` first.
2. Run the appropriate test command:
   - All tests: `just test`
   - Single test: `just test-single $ARGUMENTS`
3. If tests fail, read the failing test's `test.typ` file and any diff output to diagnose the issue.
4. Report results: which tests passed, which failed, and what the failures look like.

## Updating Reference Images

If the visual output has intentionally changed, update reference images with:
```bash
just test-update
```
Then verify the new references look correct.
