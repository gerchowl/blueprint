/// Test: Multiple rendering modes (detailed, collapsed, high-level)
#import "/src/exports.typ" as blueprint

#set page(width: 14cm, height: 16cm, margin: 1cm)

// Helper: create a component with internal structure and connectors
#let make-server(name) = blueprint.component(
  name,
  (
    blueprint.primitive-rect((0.3cm, 0.3cm), (2cm, 0.5cm), fill: blue.lighten(85%), stroke: 1pt + blue, radius: 2pt),
    blueprint.primitive-rect((0.3cm, 1cm), (2cm, 0.5cm), fill: green.lighten(85%), stroke: 1pt + green, radius: 2pt),
  ),
  border: true,
  border-shape: "rect",
  margin: 3mm,
  style: (fill: gray.lighten(95%), stroke: 2pt + black, radius: 5pt),
  connectors: (
    blueprint.connector("net", (0cm, 0.9cm)),
    blueprint.connector("storage", (2.6cm, 0.9cm)),
  ),
)

// --- Detailed mode: shows all internal content, border, and connectors ---
#let server-detailed = make-server("detailed")
#blueprint.render(server-detailed, mode: "detailed")

// --- Collapsed mode: border + connectors only, no internal content ---
#let server-collapsed = make-server("collapsed")
#let server-collapsed = blueprint.place-component(server-collapsed, (0cm, 3.5cm))
#blueprint.render(server-collapsed, mode: "collapsed")

// --- High-level mode: minimal representation ---
#let server-high = make-server("high-level")
#let server-high = blueprint.place-component(server-high, (0cm, 7cm))
#blueprint.render(server-high, mode: "high-level")

// --- Side-by-side comparison with a different component ---
#let make-database(name) = blueprint.component(
  name,
  (
    blueprint.primitive-rect((0.2cm, 0.2cm), (1.8cm, 0.4cm), fill: purple.lighten(85%), stroke: 1pt + purple),
    blueprint.primitive-rect((0.2cm, 0.8cm), (1.8cm, 0.4cm), fill: purple.lighten(75%), stroke: 1pt + purple),
    blueprint.primitive-circle((2.5cm, 0.7cm), 0.2cm, fill: red.lighten(80%), stroke: 1pt + red),
  ),
  border: true,
  border-shape: "rect",
  margin: 2mm,
  style: (fill: purple.lighten(95%), stroke: 1pt + purple, radius: 4pt),
  connectors: (
    blueprint.connector("read", (0cm, 0.7cm)),
    blueprint.connector("write", (3cm, 0.7cm)),
  ),
)

// Detailed
#let db-detailed = make-database("db-detailed")
#let db-detailed = blueprint.place-component(db-detailed, (6cm, 0cm))
#blueprint.render(db-detailed, mode: "detailed")

// Collapsed
#let db-collapsed = make-database("db-collapsed")
#let db-collapsed = blueprint.place-component(db-collapsed, (6cm, 3.5cm))
#blueprint.render(db-collapsed, mode: "collapsed")

// High-level
#let db-high = make-database("db-high")
#let db-high = blueprint.place-component(db-high, (6cm, 7cm))
#blueprint.render(db-high, mode: "high-level")
