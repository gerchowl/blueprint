/// Test: Color variations and transparency
#import "/src/exports.typ" as blueprint

#set page(width: 14cm, height: 10cm, margin: 1cm)

// Test different color lightness levels
#let colors = (red, blue, green, purple, orange, teal, yellow, maroon)
#let lightness-levels = (60%, 70%, 80%, 90%)

// Row 1: Different colors at 80% lightness
#let y-offset = 0cm
#for (i, color) in colors.enumerate() {
  let x = i * 1.5cm
  let rect = blueprint.primitive-rect(
    (x, y-offset),
    (1.2cm, 0.8cm),
    fill: color.lighten(80%),
    stroke: 1pt + color,
    radius: 3pt,
  )
  blueprint.render(rect)
}

// Row 2: Blue at different lightness levels
#let y-offset = 1.5cm
#for (i, lightness) in lightness-levels.enumerate() {
  let x = i * 1.5cm
  let rect = blueprint.primitive-rect(
    (x, y-offset),
    (1.2cm, 0.8cm),
    fill: blue.lighten(lightness),
    stroke: 1pt + blue,
    radius: 3pt,
  )
  blueprint.render(rect)
}

// Row 3: Circles with different colors
#let y-offset = 3cm
#for (i, color) in colors.enumerate() {
  let x = i * 1.5cm + 0.6cm
  let circle = blueprint.primitive-circle(
    (x, y-offset + 0.6cm),
    0.5cm,
    fill: color.lighten(80%),
    stroke: 1pt + color,
  )
  blueprint.render(circle)
}

// Row 4: More rectangles with gradient-like colors (without using components)
#let y-offset = 4.5cm
#let gradient-colors = (red, orange, yellow, green, teal, blue, purple)
#for (i, color) in gradient-colors.enumerate() {
  let rect = blueprint.primitive-rect(
    (i * 1.5cm, y-offset),
    (1.2cm, 0.8cm),
    fill: color.lighten(85%),
    stroke: 1pt + color,
    radius: 5pt,
  )
  blueprint.render(rect)
}

// Row 5: Monochrome variations (grayscale)
#let y-offset = 6.5cm
#let gray-levels = (10%, 30%, 50%, 70%, 90%)
#for (i, level) in gray-levels.enumerate() {
  let rect = blueprint.primitive-rect(
    (i * 2cm, y-offset),
    (1.5cm, 0.8cm),
    fill: black.lighten(level),
    stroke: 1pt + black,
    radius: 0pt,
  )
  blueprint.render(rect)
}

