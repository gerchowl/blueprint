/// Test: Rectangle primitives with various styles
#import "/src/exports.typ" as blueprint

#set page(width: 12cm, height: 8cm, margin: 1cm)

// Test parameters: (x-pos, color, radius, stroke-width)
#let test-cases = (
  (0cm, red, 0pt, 2pt),
  (3cm, blue, 5pt, 1pt),
  (6cm, green, 0pt, 1pt),
  (9cm, orange, 10pt, 1pt),
)

// DRY: Create and render rectangles using test parameters
#for (x, color, radius, stroke-width) in test-cases {
  let rect = blueprint.primitive-rect(
    (x, 0pt),
    (2cm, 1cm),
    fill: color.lighten(80%),
    stroke: stroke-width + color,
    radius: radius,
  )
  blueprint.render(rect)
}

// Test without fill
#let rect-no-fill = blueprint.primitive-rect(
  (0cm, 2cm),
  (2cm, 1cm),
  fill: none,
  stroke: 2pt + black,
  radius: 0pt,
)
#blueprint.render(rect-no-fill)

// Test thick border
#let rect-thick = blueprint.primitive-rect(
  (3cm, 2cm),
  (2cm, 1cm),
  fill: purple.lighten(80%),
  stroke: 5pt + purple,
  radius: 3pt,
)
#blueprint.render(rect-thick)

