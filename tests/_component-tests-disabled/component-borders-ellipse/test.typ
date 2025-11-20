/// Test: Components with elliptical borders
#import "/src/exports.typ" as blueprint

#set page(width: 12cm, height: 6cm, margin: 1cm)

// Helper function to create component with elliptical border (DRY)
#let make-ellipse-component(name, x, y, color, margin, stroke-width) = {
  let comp = blueprint.component(
    name,
    (
      blueprint.primitive-ellipse((1.2cm, 0.6cm), 0.8cm, 0.4cm, fill: white),
    ),
    border: true,
    border-shape: "ellipse",
    margin: margin,
    style: (
      fill: color.lighten(90%),
      stroke: stroke-width + color,
    ),
  )
  blueprint.place-component(name, (x, y))
  blueprint.render(comp)
}

// Test parameters: (name, x, y, color, margin, stroke-width)
#let test-cases = (
  ("ellipse-1", 0cm, 0cm, red, 2mm, 2pt),
  ("ellipse-2", 3cm, 0cm, blue, 2mm, 1pt),
  ("ellipse-3", 6cm, 0cm, green, 3mm, 1pt),
  ("ellipse-4", 9cm, 0cm, purple, 2mm, 1pt),
)

// Execute all test cases
#for (name, x, y, color, margin, stroke) in test-cases {
  make-ellipse-component(name, x, y, color, margin, stroke)
}

// Test without fill
#let comp-no-fill = blueprint.component(
  "ellipse-no-fill",
  (
    blueprint.primitive-ellipse((1.2cm, 0.6cm), 0.8cm, 0.4cm, fill: gray.lighten(90%)),
  ),
  border: true,
  border-shape: "ellipse",
  margin: 2mm,
  style: (
    fill: none,
    stroke: 2pt + black,
  ),
)
#blueprint.place-component("ellipse-no-fill", (0cm, 2.5cm))
#blueprint.render(comp-no-fill)

