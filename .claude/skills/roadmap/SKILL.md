---
name: roadmap
description: Show the current project roadmap status and help plan implementation of the next milestone features from the PRD.
allowed-tools: Read, Grep, Glob
---

Analyze the current implementation status against the PRD roadmap.

## Steps

1. Read `PRD.md` for the full requirements and milestone definitions.
2. Read `src/lib.typ` exports and key source files to assess what's implemented.
3. Check `tests/` to see what has test coverage.
4. Compare against the v0.2.0 milestone checklist from the PRD:

### v0.2.0 Milestone (from PRD)

- [ ] Connector grouping fully functional (US-3.2)
- [ ] Multiple rendering modes working end-to-end (US-2.1)
- [ ] Component inheritance (US-1.3)
- [ ] Component instances with variations (US-1.2)
- [ ] Manhattan routing (US-6.1)
- [ ] Style inheritance and themes (US-5.2)
- [ ] 10+ working examples

### Known Blockers

- `place-component()` / `state().get()` context issue blocks component-level tests
- `calculate-bounds()` in `utils.typ` returns zero bounds (placeholder)
- Arrow marks/decorations in `edge.typ` are TODO

5. Report: which features are partially implemented vs missing, which are blocked, and suggest an implementation order based on dependencies.
