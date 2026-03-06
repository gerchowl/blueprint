/// Simple example: Basic component with connectors and edges
#import "../src/lib.typ" as blueprint
#import "../src/deps.typ": cetz

#set page(width: 15cm, height: 10cm, margin: 1cm)

= Simple Component Example

This example demonstrates creating components with connectors and edges.

// Create a CPU component
#let cpu = blueprint.component(
  "cpu",
  (
    blueprint.primitive-rect((0.3cm, 0.3cm), (2cm, 1cm), fill: gray.lighten(80%), stroke: 1pt + gray),
  ),
  border: true,
  border-shape: "rect",
  margin: 3mm,
  style: (fill: blue.lighten(95%), stroke: 2pt + blue, radius: 3pt),
  connectors: (
    blueprint.connector("bus", (1.3cm, 0cm)),
    blueprint.connector("memory", (2.6cm, 0.8cm)),
  ),
)
#blueprint.render(cpu)

// Create a memory component
#let mem = blueprint.component(
  "memory",
  (
    blueprint.primitive-rect((0.2cm, 0.2cm), (1.5cm, 0.6cm), fill: green.lighten(85%), stroke: 1pt + green),
  ),
  border: true,
  border-shape: "rect",
  margin: 2mm,
  style: (fill: green.lighten(95%), stroke: 1pt + green, radius: 3pt),
  connectors: (
    blueprint.connector("data", (0cm, 0.5cm)),
  ),
)
#let mem = blueprint.place-component(mem, (6cm, 0cm))
#blueprint.render(mem)

// Draw an edge between components
#{
  cetz.canvas({
    let eth = blueprint.edge-style("bus-link", stroke: 2pt + blue, marks: "<->")
    blueprint.connect-points((3.2cm, 0.8cm), (5.6cm, 0.5cm), style: eth)
  })
}

// Render the CPU in collapsed mode
#let cpu-collapsed = blueprint.place-component(cpu, (0cm, 4cm))
#blueprint.render(cpu-collapsed, mode: "collapsed")
