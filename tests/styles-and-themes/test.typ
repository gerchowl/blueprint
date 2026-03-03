/// Test: Styles and themes
#import "/src/exports.typ" as blueprint

#set page(width: 14cm, height: 8cm, margin: 1cm)

// --- Define custom styles ---
#let danger-style = blueprint.style("danger",
  component-style: (fill: red.lighten(90%), stroke: 2pt + red, radius: 0pt),
  connector-style: (fill: red.lighten(80%), stroke: 1pt + red, size: 5pt),
  edge-style: (stroke: 2pt + red, marks: "->"),
)

#let info-style = blueprint.style("info",
  component-style: (fill: blue.lighten(90%), stroke: 1pt + blue, radius: 5pt),
)

#let success-style = blueprint.style("success",
  component-style: (fill: green.lighten(90%), stroke: 1pt + green, radius: 8pt),
)

// --- Style inheritance: warning inherits from danger ---
#let warning-style = blueprint.style("warning",
  base: danger-style,
  component-style: (fill: yellow.lighten(80%), stroke: 2pt + orange),
)

// --- Apply styles to components (parametrized) ---
#let style-cases = (
  ("danger-comp",  danger-style.component,  (0cm, 0cm)),
  ("info-comp",    info-style.component,    (3cm, 0cm)),
  ("success-comp", success-style.component, (6cm, 0cm)),
  ("warning-comp", warning-style.component, (9cm, 0cm)),
)

#for (name, comp-style, pos) in style-cases {
  let comp = blueprint.component(name,
    (blueprint.primitive-rect((0.2cm, 0.2cm), (1.5cm, 0.6cm), fill: white),),
    border: true, border-shape: "rect", margin: 2mm,
    style: comp-style,
  )
  let comp = blueprint.place-component(comp, pos)
  blueprint.render(comp)
}

// --- Edge styles: reusable connection types ---
#{
  blueprint.cetz.canvas({
    let eth = blueprint.edge-style("ethernet", stroke: 2pt + blue, marks: "->")
    let pcie = blueprint.edge-style("pcie", stroke: 3pt + purple, marks: "<->")
    let serial = blueprint.edge-style("serial", stroke: 1pt + gray, marks: "->", dash: "dashed")
    blueprint.connect-points((0cm, 4cm), (4cm, 4cm), style: eth)
    blueprint.connect-points((0cm, 5cm), (4cm, 5cm), style: pcie)
    blueprint.connect-points((0cm, 6cm), (4cm, 6cm), style: serial)
  })
}
