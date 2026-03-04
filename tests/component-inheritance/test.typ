/// Test: Component inheritance via component-extend
#import "/src/exports.typ" as blueprint

#set page(width: 14cm, height: 11cm, margin: 1cm)

// --- Base component ---
#let base = blueprint.component(
  "base-server",
  (
    blueprint.primitive-rect((0.3cm, 0.3cm), (2cm, 1cm), fill: gray.lighten(85%), stroke: 1pt + gray),
  ),
  border: true,
  border-shape: "rect",
  margin: 2mm,
  style: (fill: gray.lighten(95%), stroke: 1pt + gray, radius: 3pt),
)
#blueprint.render(base)

// --- Extended: override style only ---
#let web-server = blueprint.component-extend(base, "web-server", (
  style: (fill: blue.lighten(90%), stroke: 2pt + blue),
  connectors: (
    blueprint.connector("http", (0cm, 0.8cm)),
  ),
))
#let web-server = blueprint.place-component(web-server, (0cm, 3cm))
#blueprint.render(web-server)

// --- Extended: add additional content and connectors ---
#let db-server = blueprint.component-extend(base, "db-server", (
  style: (fill: green.lighten(90%), stroke: 2pt + green),
  content: (
    blueprint.primitive-circle((3.5cm, 0.8cm), 0.3cm, fill: green.lighten(70%), stroke: 1pt + green),
  ),
  connectors: (
    blueprint.connector("sql", (0cm, 0.8cm)),
    blueprint.connector("backup", (2.6cm, 0cm)),
  ),
))
#let db-server = blueprint.place-component(db-server, (5cm, 0cm))
#blueprint.render(db-server)

// --- Extended: override margin ---
#let monitoring = blueprint.component-extend(base, "monitoring", (
  style: (fill: orange.lighten(90%), stroke: 2pt + orange),
  margin: 4mm,
))
#let monitoring = blueprint.place-component(monitoring, (5cm, 3cm))
#blueprint.render(monitoring)

// --- Chain: extend from an already-extended component ---
#let web-api = blueprint.component-extend(web-server, "web-api", (
  style: (fill: purple.lighten(90%), stroke: 2pt + purple),
  connectors: (
    blueprint.connector("grpc", (2.6cm, 0.8cm)),
  ),
))
#let web-api = blueprint.place-component(web-api, (10cm, 0cm))
#blueprint.render(web-api)
