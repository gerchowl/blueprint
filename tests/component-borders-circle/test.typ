/// Test: Components with circular borders
#import "/src/exports.typ" as blueprint

#set page(width: 12cm, height: 6cm, margin: 1cm)

// Helper function to create component with circular border (DRY)
#let make-circle-component(name, x, y, color, margin, stroke-width) = {
  let comp = blueprint.component(
    name,
    (
      blueprint.primitive-circle((1cm, 0.8cm), 0.5cm, fill: white),
    ),
    border: true,
    border-shape: "circle",
    margin: margin,
    style: (
      fill: color.lighten(90%),
      stroke: stroke-width + color,
    ),
  )
  let comp = blueprint.place-component(comp, (x, y))
  blueprint.render(comp)
}

// Test parameters: (name, x, y, color, margin, stroke-width)
#let test-cases = (
  ("circle-1", 0cm, 0cm, red, 2mm, 2pt),
  ("circle-2", 3cm, 0cm, blue, 2mm, 1pt),
  ("circle-3", 6cm, 0cm, green, 3mm, 1pt),
  ("circle-4", 9cm, 0cm, purple, 2mm, 1pt),
)

// Execute all test cases
#for (name, x, y, color, margin, stroke) in test-cases {
  make-circle-component(name, x, y, color, margin, stroke)
}

// Test without fill
#let comp-no-fill = blueprint.component(
  "circle-no-fill",
  (
    blueprint.primitive-circle((1cm, 0.8cm), 0.5cm, fill: gray.lighten(90%)),
  ),
  border: true,
  border-shape: "circle",
  margin: 2mm,
  style: (
    fill: none,
    stroke: 2pt + black,
  ),
)
#let comp-no-fill = blueprint.place-component(comp-no-fill, (0cm, 2.5cm))
#blueprint.render(comp-no-fill)
