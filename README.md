# Blueprint - Hierarchical Diagram Package for Typst

A comprehensive Typst package for creating hierarchical technical component diagrams with nested components, built directly on CeTZ for maximum control.

## Features

- **Nested Components**: Create components with their own coordinate systems
- **Multiple Rendering Modes**: Detailed, collapsed, and high-level views
- **Component Inheritance**: Extend and customize components
- **Connector System**: Grouped and individual connectors with flexible display
- **Edge Routing**: Direct, rectangular, Manhattan, and manual routing
- **Reusable Styles**: Define and apply styles to components, connectors, and edges
- **Flexible Positioning**: Absolute and relative positioning with anchor points
- **Primitives**: Standard shapes (rectangles, circles, ellipses) with anchor points

## Installation

```typst
#import "@preview/blueprint:0.1.0": *
```

## Quick Start

```typst
#import "@preview/blueprint:0.1.0": *
#import "@preview/cetz:0.3.2": *

// Create a simple component
#let my-component = component(
  name: "processor",
  content: (
    primitive-rect((0pt, 0pt), (2cm, 1cm), fill: blue.lighten(80%)),
  ),
  connectors: (
    connector("input", (0pt, 0.5cm)),
    connector("output", (2cm, 0.5cm)),
  ),
)

// Place and render the component
#place-component("processor", (5cm, 5cm))
#render(my-component)
```

## Core Concepts

### Components

Components are the building blocks of hierarchical diagrams. Each component has:
- **Content**: Primitives, other components, or raw CeTZ drawings
- **Connectors**: Interface points for connections
- **Canvas**: Own coordinate system
- **Style**: Visual appearance
- **Display Mode**: Detailed, collapsed, or high-level

### Connectors

Connectors define interface points on components:
- **Individual**: Single connection point
- **Grouped**: Multiple connectors shown as `[1..10]` or expanded
- **Positioned**: Absolute or relative to component bounds

### Edges

Edges connect components via connectors:
- **Styles**: Reusable edge styles (stroke, marks, routing)
- **Routing**: Direct, rectangular, Manhattan, or manual
- **Anchors**: Connect to primitive anchor points

### Positioning

- **Absolute**: Direct coordinates
- **Relative**: Position relative to other objects with gaps
- **Anchors**: `(left|center|right, top|center|bottom)`

## API Reference

### Components

```typst
// Create a component
#let comp = component(
  name: "my-component",
  content: (...),
  origin: (center, center),
  internal-origin: (left, top),
  border: true,
  margin: 2mm,
  style: none,
  connectors: (),
  parent: none,
)

// Extend a component
#let extended = component-extend("base-component", "new-component", (
  content: (...),
  style: (...),
))

// Place a component
#place-component("my-component", (5cm, 5cm), anchor: (center, center))

// Create instances
#let instances = instance(comp, count: 3, variations: (:))

// Render a component
#render(comp, mode: "detailed") // or "collapsed" or "high-level"
```

### Connectors

```typst
// Create a connector
#let conn = connector(
  name: "input",
  position: (0pt, 0.5cm),
  group: none,
  count: 1,
  group-display: "auto",
  group-label: none,
  style: none,
)

// Get a connector from a component
#let conn = get-connector("component-name", "connector-name", index: none)
```

### Edges

```typst
// Define an edge style
#let eth-1gb = edge-style(
  name: "ethernet-1gb",
  stroke: 1pt + blue,
  marks: "->",
  routing: "manhattan",
)

// Connect two points
#connect-points((0pt, 0pt), (5cm, 5cm), style-name: "ethernet-1gb")

// Connect two connectors
#connect(from-connector, to-connector, style-name: "ethernet-1gb")

// Connect to a primitive anchor
#connect-to-anchor(primitive, "top-right", (5cm, 5cm), style-name: "ethernet-1gb")
```

### Primitives

```typst
// Rectangle
#let rect = primitive-rect(
  position: (0pt, 0pt),
  size: (2cm, 1cm),
  fill: blue.lighten(80%),
  stroke: 1pt + black,
  radius: 2pt,
)

// Circle
#let circle = primitive-circle(
  center: (1cm, 1cm),
  radius: 0.5cm,
  fill: red.lighten(80%),
  stroke: 1pt + black,
)

// Ellipse
#let ellipse = primitive-ellipse(
  center: (1cm, 1cm),
  radius-x: 1cm,
  radius-y: 0.5cm,
  fill: green.lighten(80%),
  stroke: 1pt + black,
)

// Access anchor points
#let top-right = rect.get-anchor("top-right")
```

### Positioning

```typst
// Relative positioning
#let pos = relative("reference-object", (right, center), gap: 1cm)

// Relative with specific anchors
#let pos = relative-with-anchor("ref", (right, center), (left, center), gap: 1cm)
```

### Styles

```typst
// Define a style
#let my-style = style(
  name: "custom",
  component-style: (fill: blue.lighten(90%), stroke: 2pt + blue),
  connector-style: (size: 6pt, fill: blue),
  edge-style: (stroke: 1pt + blue, marks: "->"),
  extends: none,
)

// Define a theme
#theme("my-theme", (
  "component-style": (...),
  "connector-style": (...),
))
```

## Examples

### Simple Component

```typst
#import "@preview/blueprint:0.1.0": *

#let cpu = component(
  name: "cpu",
  content: (
    primitive-rect((0pt, 0pt), (2cm, 1.5cm), fill: gray.lighten(80%)),
  ),
  connectors: (
    connector("bus", (1cm, 0pt)),
    connector("memory", (2cm, 0.75cm)),
  ),
)

#place-component("cpu", (2cm, 2cm))
#render(cpu)
```

### Nested Components

```typst
#let inner = component(
  name: "inner",
  content: (
    primitive-circle((0.5cm, 0.5cm), 0.3cm, fill: blue.lighten(80%)),
  ),
)

#let outer = component(
  name: "outer",
  content: (
    primitive-rect((0pt, 0pt), (3cm, 2cm), fill: gray.lighten(90%)),
    render(inner, mode: "detailed"),
  ),
  parent: none,
)

#place-component("outer", (1cm, 1cm))
#render(outer)
```

### Connected Components

```typst
#let comp1 = component(
  name: "comp1",
  content: (...),
  connectors: (connector("out", (2cm, 1cm))),
)

#let comp2 = component(
  name: "comp2",
  content: (...),
  connectors: (connector("in", (0pt, 1cm))),
)

#place-component("comp1", (1cm, 1cm))
#place-component("comp2", (4cm, 1cm))

#connect(
  get-connector("comp1", "out"),
  get-connector("comp2", "in"),
  style-name: "ethernet-1gb",
)
```

## License

MIT

