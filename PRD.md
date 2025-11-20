# Product Requirements Document: Blueprint

**Package Name:** Blueprint  
**Version:** 0.1.0  
**Last Updated:** 2024-11-20  
**Status:** In Development

---

## Executive Summary

Blueprint is a Typst package for creating hierarchical technical diagrams with nested components. It enables users to create detailed component diagrams that can be rendered at multiple abstraction levels (detailed, collapsed, high-level) while maintaining internal logic and relationships. Built on CeTZ for maximum control over rendering and coordinate systems.

---

## Problem Statement

Technical documentation often requires diagrams showing system architectures at multiple levels of detail. Current diagramming solutions force users to:
- Create separate diagrams for different abstraction levels
- Manually maintain consistency across diagram versions
- Rebuild connections when changing detail levels
- Manually manage component positioning and sizing

**Blueprint solves this by:** Providing a single-source-of-truth diagram definition that can render at multiple abstraction levels, with automatic component sizing, flexible connector management, and hierarchical coordinate systems.

---

## Target Users

### Primary Users
1. **System Architects** - Creating technical architecture diagrams
2. **Hardware Engineers** - Documenting hardware component relationships
3. **Technical Writers** - Producing multi-level technical documentation
4. **Software Architects** - Visualizing service/component architectures

### User Expertise
- Intermediate to advanced Typst users
- Comfortable with code-based diagram definitions
- Need for precise, reusable, and maintainable diagrams

---

## User Stories

### Epic 1: Component Definition and Management

**US-1.1: Define Reusable Components**
```
As a technical architect,
I want to define a component with its internal structure once,
So that I can reuse it throughout my diagrams with consistent appearance.
```

**Acceptance Criteria:**
- Can define a component with name, content, and styling
- Can specify component origin/anchor point
- Can configure border and margin settings
- Component definition is reusable across diagrams

**US-1.2: Component Instances and Variations**
```
As a system designer,
I want to create multiple instances of a component with slight variations,
So that I can show replicated elements (e.g., "3x identical servers") without duplicating definitions.
```

**Acceptance Criteria:**
- Can create N instances of a component
- Can override specific properties per instance
- Can indicate multiplicity visually (e.g., "x3")

**US-1.3: Component Inheritance**
```
As a hardware engineer,
I want to extend a base component and override specific properties,
So that I can create component families (e.g., "RouterBase" → "Router-5G", "Router-10G").
```

**Acceptance Criteria:**
- Can extend existing component definitions
- Can override any component property
- Inheritance chain is preserved

### Epic 2: Hierarchical Rendering

**US-2.1: Multi-Level Rendering**
```
As a technical writer,
I want to render the same diagram at different detail levels (detailed/collapsed/high-level),
So that I can show overview and detailed views in the same document without maintaining separate diagrams.
```

**Acceptance Criteria:**
- `render(component, mode: "detailed")` - Shows all internal structure
- `render(component, mode: "collapsed")` - Shows component as box with connectors
- `render(component, mode: "high-level")` - Shows minimal representation
- All modes maintain correct positioning and connections

**US-2.2: Nested Coordinate Systems**
```
As a diagram creator,
I want each component to have its own coordinate system,
So that I can position elements inside a component independently of the parent diagram.
```

**Acceptance Criteria:**
- Each component has isolated coordinate system
- Can position elements inside component using local coordinates
- Parent-child coordinate transformations work correctly
- Can nest components within components

### Epic 3: Connector System

**US-3.1: Define Connection Interfaces**
```
As a system architect,
I want to define connectors on my components,
So that I can specify where connections attach to components.
```

**Acceptance Criteria:**
- Can define named connectors at specific positions
- Connectors can be placed on component borders (auto-calculated)
- Can specify connector styling independently

**US-3.2: Connector Grouping**
```
As a hardware designer,
I want to group identical connectors (e.g., "10x Ethernet ports"),
So that I can manage them as a unit and decide their display mode.
```

**Acceptance Criteria:**
- Can group connectors with a group name
- Group display modes:
  - **Collapsed:** `[1..10] connectorX`
  - **Expanded:** `[1]-[2]-[3]...-[10] connectorX`
  - **Individual:** Each connector shown separately
- Display mode changes based on rendering level (auto-collapse in high-level view)

**US-3.3: Flexible Connection**
```
As a technical architect,
I want to connect specific connectors between components,
So that I can show precise relationships (e.g., "Server A, port 3 → Switch B, port 7").
```

**Acceptance Criteria:**
- Can connect individual connectors: `connect(compA.conn(3), compB.conn(7), style)`
- Can connect to connector groups: `connect(compA.conn-group, compB.conn)`
- Connections maintain logic when rendering mode changes

### Epic 4: Positioning and Layout

**US-4.1: Absolute Positioning**
```
As a diagram creator,
I want to position elements using absolute coordinates within a component,
So that I have precise control over element placement.
```

**Acceptance Criteria:**
- Can use `(x, y)` coordinates within component coordinate system
- Coordinates are in Typst length units (pt, mm, cm, etc.)
- Origin point configurable per component

**US-4.2: Relative Positioning**
```
As a diagram creator,
I want to position elements relative to other elements with anchor points,
So that I can create flexible layouts that adapt to component size changes.
```

**Acceptance Criteria:**
- Syntax: `relative(ref-object, (right, center), gap: 1mm)`
- Anchor points: `left|center|right` × `top|center|bottom`
- Gap specification: `1mm` (both) or `(x, y)` for independent gaps
- Reference object must be defined before use

**US-4.3: Automatic Border Sizing**
```
As a component designer,
I want component borders to automatically size to their content,
So that I don't manually calculate component dimensions.
```

**Acceptance Criteria:**
- Border auto-sizes to content bounds + margin
- Margin is configurable per component
- Border can be disabled for logical grouping without visual border
- Bounds calculation includes all internal elements and connectors

### Epic 5: Styling System

**US-5.1: Reusable Styles**
```
As a documentation maintainer,
I want to define reusable styles for components, connectors, and edges,
So that I can ensure consistent appearance and easily update styling.
```

**Acceptance Criteria:**
- Can define named styles: `style(name, component-style, connector-style, edge-style)`
- Styles can be applied to components/connectors/edges
- Style properties include: fill, stroke, border-style, border-radius, etc.

**US-5.2: Style Inheritance**
```
As a theme designer,
I want styles to extend other styles,
So that I can create style hierarchies and themes.
```

**Acceptance Criteria:**
- Styles can extend base styles
- Component-level overrides work correctly
- Global theme can be set and applied

**US-5.3: Edge Styles**
```
As a network diagram creator,
I want to define reusable edge/connection styles,
So that I can show different connection types (e.g., "1GB Ethernet", "10GB Ethernet", "PCIe").
```

**Acceptance Criteria:**
- Syntax: `#let eth-1gb = edge-style("name", stroke, marks, routing)`
- Can specify: line style, arrow marks, colors, routing
- Styles reusable: `connect(a, b, eth-1gb)`

### Epic 6: Edge Routing

**US-6.1: Multiple Routing Modes**
```
As a diagram creator,
I want to choose how connections are routed between components,
So that I can create clear, readable diagrams.
```

**Acceptance Criteria:**
- **Direct:** Straight line between connectors
- **Rectangular:** Only horizontal and vertical segments
- **Manhattan:** Smart rectangular routing with automatic waypoints
- **Manual:** User-specified waypoints for custom paths
- Routing mode selectable per connection

**US-6.2: Future: Intelligent Routing**
```
As a complex diagram creator,
I want connections to automatically avoid crossing other components,
So that diagrams remain readable even with many connections.
```

**Acceptance Criteria (Future):**
- Automatic path planning to avoid components
- Minimal path bending
- User can still override with manual routing

---

## Technical Requirements

### TR-1: Core Architecture

**TR-1.1: CeTZ Integration**
- Package built directly on CeTZ 0.4.2
- Each component wraps a CeTZ canvas
- Coordinate transformations between parent/child canvases

**TR-1.2: Modular Structure**
```
src/
├── lib.typ         # Main entry point, exports
├── deps.typ        # Centralized dependency imports (CeTZ)
├── exports.typ     # Testing exports
├── component.typ   # Component system
├── canvas.typ      # Nested canvas management
├── connector.typ   # Connector system
├── edge.typ        # Edge routing and styles
├── style.typ       # Style system
├── layout.typ      # Positioning and layout
├── primitives.typ  # Drawing primitives
└── utils.typ       # Helper functions
```

**TR-1.3: State Management**
- Use Typst `state()` for registries (components, canvases, styles)
- Stateless rendering where possible
- Clear separation of definition and rendering phases

### TR-2: API Design

**TR-2.1: Consistent Function Naming**
- Components: `component()`, `component-extend()`, `instance()`
- Connectors: `connector()`, `render-connector()`
- Connections: `connect()`, `connect-to-anchor()`
- Positioning: `relative()`, `anchor-position()`
- Styling: `style()`, `edge-style()`, `apply-style()`

**TR-2.2: Clear Parameter Patterns**
- Positional parameters for required values
- Named parameters for optional configuration
- Consistent parameter ordering across functions
- Default values for common use cases

**TR-2.3: Error Handling**
- Clear error messages for common mistakes
- Validation of coordinate systems
- Warning for ambiguous configurations

### TR-3: Performance

**TR-3.1: Efficient Rendering**
- Lazy evaluation where possible
- Avoid redundant coordinate transformations
- Cache bounds calculations

**TR-3.2: Scalability**
- Handle diagrams with 50+ components
- Support deep nesting (5+ levels)
- Maintain performance with 100+ connections

### TR-4: Documentation

**TR-4.1: Code Documentation**
- Docstrings for all public functions (Tidy-compatible)
- Parameter descriptions with types
- Usage examples in docstrings

**TR-4.2: User Documentation**
- Comprehensive manual (docs/manual.typ)
- Example gallery (examples/)
- API reference (auto-generated from docstrings)
- Migration guide for updates

### TR-5: Testing

**TR-5.1: Test Coverage**
- Unit tests for core functions
- Integration tests for complete diagrams
- Visual regression tests (Tytanic)
- Test coverage across rendering modes

**TR-5.2: Test Infrastructure**
- Tytanic 0.3.1 for test runner
- Reference images for visual regression
- CI integration for automated testing

---

## Success Criteria

### MVP (v0.1.0) - Current Status
✅ Core component system implemented  
✅ Nested canvas/coordinate systems  
✅ Basic connector system  
✅ Edge routing (direct, rectangular)  
✅ Style system foundation  
✅ Relative positioning  
✅ Auto-sizing borders  
✅ Testing infrastructure (Tytanic)  

### v0.2.0 - Enhanced Features
- [ ] Connector grouping fully functional
- [ ] Multiple rendering modes (detailed/collapsed/high-level)
- [ ] Component inheritance
- [ ] Component instances with variations
- [ ] Manhattan routing
- [ ] Style inheritance and themes
- [ ] 10+ working examples

### v0.3.0 - Production Ready
- [ ] Intelligent routing (avoid crossings)
- [ ] Performance optimizations
- [ ] Complete documentation
- [ ] Gallery of real-world examples
- [ ] Published to Typst package registry

### Key Metrics
- **Usability:** Users can create a 3-level hierarchical diagram in < 50 lines of code
- **Reusability:** 80% of diagram elements use reusable components/styles
- **Flexibility:** Same diagram definition renders at 3+ abstraction levels
- **Performance:** Diagrams with 50 components render in < 5 seconds
- **Documentation:** 100% of public API documented with examples

---

## Non-Goals (Out of Scope)

### Explicitly NOT in Scope
- **Interactive diagrams** - This is a static diagram package
- **Automatic layout algorithms** - Users specify positioning explicitly
- **Graph visualization** - Not a graph layout engine (see Graphviz)
- **UML/specific diagram standards** - General-purpose component diagrams
- **Animation/transitions** - Static rendering only
- **Data-driven diagrams** - No direct CSV/JSON import (users write Typst)

### Might Consider Later
- Integration with Fletcher for specialized arrows/marks
- SVG/image export utilities
- Template library for common patterns
- Interactive editing tools (separate project)

---

## Dependencies

### Required
- **CeTZ 0.4.2+** - Core drawing and canvas system
- **Typst 0.13.0+** - Minimum Typst version

### Development Tools
- **Tytanic 0.3.1** - Test runner
- **Tidy 0.4.3** - Documentation generation
- **Just** - Task automation

### Optional
- **utpm** - Local Typst package management

---

## Risks and Mitigations

### Technical Risks

**Risk: CeTZ coordinate system limitations**
- *Impact:* High - Core functionality depends on CeTZ
- *Mitigation:* Wrapper layer abstracts CeTZ, can swap implementation
- *Status:* Low risk - CeTZ proven suitable

**Risk: Typst state management complexity**
- *Impact:* Medium - Complex nesting may hit Typst limitations
- *Mitigation:* Functional approach where possible, minimize state
- *Status:* Medium risk - Monitoring

**Risk: Performance with large diagrams**
- *Impact:* Medium - Slow rendering hurts UX
- *Mitigation:* Lazy evaluation, caching, performance tests
- *Status:* Low risk - Early tests show good performance

### Adoption Risks

**Risk: Learning curve too steep**
- *Impact:* High - Complex API reduces adoption
- *Mitigation:* Comprehensive examples, template library, clear docs
- *Status:* Medium risk - Addressing through documentation

**Risk: Fletcher overlap/competition**
- *Impact:* Medium - Users may stick with Fletcher
- *Mitigation:* Clear differentiation (hierarchical components vs. node-edge diagrams)
- *Status:* Low risk - Different use cases

---

## Future Enhancements

### Phase 2 (v0.4.0+)
- Animation support (show/hide components over time)
- SVG export with embedded metadata
- Integration with data sources (JSON/TOML component definitions)
- Component library (common hardware/software components)

### Phase 3 (v0.5.0+)
- Constraint-based layout (components maintain relationships)
- Advanced routing (Dijkstra, A* pathfinding)
- Component templates with parameters
- Interactive preview mode (web-based)

### Community Requests
- Integration with other Typst diagramming packages
- Standard library of technical components
- Theme marketplace
- Collaborative editing support

---

## Appendix

### A: Example Use Cases

1. **Data Center Architecture**
   - Racks with servers (nested components)
   - Network connections between servers
   - Multiple abstraction levels (rack → server → CPU/RAM)

2. **PCB Layout Documentation**
   - Components with pin layouts
   - Trace connections between pins
   - High-level (component names) vs detailed (all pins) views

3. **Software Architecture**
   - Microservices with internal structure
   - API connections between services
   - Team-level (services) vs implementation (classes/functions) views

4. **Network Topology**
   - Routers/switches with port layouts
   - Cable connections with specifications
   - Physical vs logical topology views

### B: Competitive Analysis

| Feature | Blueprint | Fletcher | Graphviz | Mermaid |
|---------|-----------|----------|----------|---------|
| Hierarchical components | ✅ Core | ❌ | ❌ | Partial |
| Multiple abstraction levels | ✅ Core | ❌ | ❌ | ❌ |
| Nested coordinate systems | ✅ Core | ❌ | ❌ | ❌ |
| Connector grouping | ✅ Core | ❌ | ❌ | ❌ |
| Reusable components | ✅ Core | Partial | ❌ | Partial |
| Auto-sizing | ✅ Core | ✅ | ✅ | ✅ |
| Built for Typst | ✅ | ✅ | ❌ | ❌ |
| Commutative diagrams | ❌ | ✅ | Partial | ❌ |
| Auto layout | ❌ | Partial | ✅ | ✅ |

**Differentiation:** Blueprint focuses on hierarchical technical diagrams with explicit positioning, while Fletcher excels at node-edge diagrams and Graphviz/Mermaid provide automatic layout.

### C: Glossary

- **Component:** A reusable diagram element with internal structure and coordinate system
- **Canvas:** A CeTZ drawing context with its own coordinate system
- **Connector:** An interface point on a component where connections attach
- **Connector Group:** Multiple identical connectors managed as a unit
- **Edge/Connection:** A line connecting two connectors with optional styling
- **Rendering Mode:** The abstraction level at which a diagram is displayed
- **Anchor Point:** A reference point on a component (e.g., center, top-left)
- **Relative Positioning:** Positioning an element based on another element's position
- **Origin:** The reference point (0,0) in a component's coordinate system

---

**Document Version:** 1.0  
**Authors:** Blueprint Development Team  
**Review Status:** Draft → Review → Approved  

