/// Test: Components with rectangular borders
#import "/src/exports.typ" as blueprint

#set page(width: 12cm, height: 6cm, margin: 1cm)

// Helper function to create component with rect border (DRY)
#let make-rect-component(name, x, y, color, radius, margin, stroke-width) = {
  let comp = blueprint.component(
    name,
    (
      blueprint.primitive-rect((0.2cm, 0.2cm), (1.6cm, 0.6cm), fill: white),
    ),
    border: true,
    border-shape: "rect",
    margin: margin,
    style: (
      fill: color.lighten(90%),
      stroke: stroke-width + color,
      radius: radius,
    ),
  )
  blueprint.place-component(name, (x, y))
  blueprint.render(comp)
}

// Test parameters: (name, x, y, color, radius, margin, stroke-width)
#let test-cases = (
  ("rect-1", 0cm, 0cm, red, 0pt, 2mm, 2pt),
  ("rect-2", 3cm, 0cm, blue, 8pt, 2mm, 1pt),
  ("rect-3", 6cm, 0cm, green, 0pt, 3mm, 1pt),
  ("rect-4", 9cm, 0cm, purple, 5pt, 2mm, 1pt),
)

// Execute all test cases
#for (name, x, y, color, radius, margin, stroke) in test-cases {
  make-rect-component(name, x, y, color, radius, margin, stroke)
}

// Test without fill
#let comp-no-fill = blueprint.component(
  "rect-no-fill",
  (
    blueprint.primitive-rect((0.2cm, 0.2cm), (1.6cm, 0.6cm), fill: gray.lighten(90%)),
  ),
  border: true,
  border-shape: "rect",
  margin: 2mm,
  style: (
    fill: none,
    stroke: 2pt + black,
    radius: 0pt,
  ),
)
#blueprint.place-component("rect-no-fill", (0cm, 2.5cm))
#blueprint.render(comp-no-fill)

// Test without border
#let comp-no-border = blueprint.component(
  "rect-no-border",
  (
    blueprint.primitive-rect((0pt, 0pt), (2cm, 1cm), fill: orange.lighten(80%), stroke: 1pt + orange),
  ),
  border: false,
  margin: 0pt,
)
#blueprint.place-component("rect-no-border", (3cm, 2.5cm))
#blueprint.render(comp-no-border)

