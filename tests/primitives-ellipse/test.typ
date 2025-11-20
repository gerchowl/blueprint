/// Test: Ellipse primitives with various styles
#import "/src/exports.typ" as blueprint

#set page(width: 12cm, height: 6cm, margin: 1cm)

// Test parameters: (x-pos, color, rx, ry, stroke-width)
#let test-cases = (
  (1.5cm, red, 1.2cm, 0.6cm, 2pt),
  (4.5cm, blue, 1.2cm, 0.6cm, 1pt),
  (7.5cm, green, 0.8cm, 1.2cm, 1pt),
  (10.5cm, orange, 1cm, 0.7cm, 1pt),
)

// DRY: Create and render ellipses using test parameters
#for (x, color, rx, ry, stroke-width) in test-cases {
  let ellipse = blueprint.primitive-ellipse(
    (x, 1.5cm),
    rx, ry,
    fill: color.lighten(80%),
    stroke: stroke-width + color,
  )
  blueprint.render(ellipse)
}

// Test without fill
#let ellipse-no-fill = blueprint.primitive-ellipse(
  (2cm, 4cm),
  1cm, 0.6cm,
  fill: none,
  stroke: 2pt + black,
)
#blueprint.render(ellipse-no-fill)

// Test thick border
#let ellipse-thick = blueprint.primitive-ellipse(
  (5cm, 4cm),
  1cm, 0.8cm,
  fill: purple.lighten(80%),
  stroke: 5pt + purple,
)
#blueprint.render(ellipse-thick)

