/// Test: Circle primitives with various styles
#import "/src/exports.typ" as blueprint

#set page(width: 12cm, height: 6cm, margin: 1cm)

// Test parameters: (x-pos, color, radius, stroke-width)
#let test-cases = (
  (1cm, red, 0.8cm, 2pt),
  (4cm, blue, 0.8cm, 1pt),
  (7cm, green, 0.6cm, 1pt),
  (10cm, purple, 1cm, 1pt),
)

// DRY: Create and render circles using test parameters
#for (x, color, radius, stroke-width) in test-cases {
  let circle = blueprint.primitive-circle(
    (x, 1.5cm),
    radius,
    fill: color.lighten(80%),
    stroke: stroke-width + color,
  )
  blueprint.render(circle)
}

// Test without fill
#let circle-no-fill = blueprint.primitive-circle(
  (2cm, 4cm),
  0.8cm,
  fill: none,
  stroke: 2pt + black,
)
#blueprint.render(circle-no-fill)

// Test thick border
#let circle-thick = blueprint.primitive-circle(
  (5cm, 4cm),
  0.8cm,
  fill: orange.lighten(80%),
  stroke: 5pt + orange,
)
#blueprint.render(circle-thick)

