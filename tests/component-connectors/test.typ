/// Test: Component connectors in different display modes
#import "/src/exports.typ" as blueprint

#set page(width: 14cm, height: 8cm, margin: 1cm)

// --- Component with individual connectors (detailed mode) ---
#let comp1 = blueprint.component(
  "server",
  (
    blueprint.primitive-rect((0.3cm, 0.3cm), (2cm, 1cm), fill: blue.lighten(85%), stroke: 1pt + blue),
  ),
  border: true,
  border-shape: "rect",
  margin: 3mm,
  style: (fill: none, stroke: 1pt + black),
  connectors: (
    blueprint.connector("eth0", (0cm, 0.8cm)),
    blueprint.connector("eth1", (2.6cm, 0.8cm)),
    blueprint.connector("power", (1.3cm, 0cm)),
  ),
)
#blueprint.render(comp1)

// --- Component with grouped connectors (collapsed display) ---
#let comp2 = blueprint.component(
  "switch",
  (
    blueprint.primitive-rect((0.3cm, 0.3cm), (3cm, 0.8cm), fill: green.lighten(85%), stroke: 1pt + green),
  ),
  border: true,
  border-shape: "rect",
  margin: 3mm,
  style: (fill: none, stroke: 1pt + green),
  connectors: (
    blueprint.connector("ports", (1.8cm, 1.4cm), group: "ethernet", count: 8, group-display: "auto"),
  ),
)
#let comp2 = blueprint.place-component(comp2, (0cm, 3cm))
#blueprint.render(comp2)

// --- Component rendered in collapsed mode (border + connectors only) ---
#let comp3 = blueprint.component(
  "db",
  (
    blueprint.primitive-rect((0.2cm, 0.2cm), (1.5cm, 0.8cm), fill: purple.lighten(85%), stroke: 1pt + purple),
  ),
  border: true,
  border-shape: "rect",
  margin: 2mm,
  style: (fill: purple.lighten(95%), stroke: 1pt + purple),
  connectors: (
    blueprint.connector("input", (0cm, 0.6cm)),
    blueprint.connector("output", (1.9cm, 0.6cm)),
  ),
)
#let comp3 = blueprint.place-component(comp3, (6cm, 0cm))
#blueprint.render(comp3, mode: "collapsed")

// --- Component in high-level mode (minimal representation) ---
#let comp4 = blueprint.component(
  "cache",
  (
    blueprint.primitive-rect((0.2cm, 0.2cm), (1.5cm, 0.8cm), fill: orange.lighten(85%), stroke: 1pt + orange),
  ),
  border: true,
  border-shape: "rect",
  margin: 2mm,
  style: (fill: orange.lighten(95%), stroke: 1pt + orange),
  connectors: (
    blueprint.connector("in", (0cm, 0.6cm)),
    blueprint.connector("out", (1.9cm, 0.6cm)),
  ),
)
#let comp4 = blueprint.place-component(comp4, (6cm, 3cm))
#blueprint.render(comp4, mode: "high-level")

// --- Custom connector style (square shape, larger size) ---
#let custom-conn-style = (size: 6pt, shape: "rect", fill: yellow.lighten(60%), stroke: 1pt + orange)
#let comp5 = blueprint.component(
  "router",
  (
    blueprint.primitive-rect((0.3cm, 0.3cm), (2cm, 0.8cm), fill: teal.lighten(85%), stroke: 1pt + teal),
  ),
  border: true,
  border-shape: "rect",
  margin: 3mm,
  style: (fill: none, stroke: 1pt + teal),
  connectors: (
    blueprint.connector("wan", (0cm, 0.7cm), style: custom-conn-style),
    blueprint.connector("lan", (2.6cm, 0.7cm), style: custom-conn-style),
  ),
)
#let comp5 = blueprint.place-component(comp5, (10cm, 0cm))
#blueprint.render(comp5)
