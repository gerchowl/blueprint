/// Test: Nested components (components containing primitives)
#import "/src/exports.typ" as blueprint

#set page(width: 14cm, height: 13cm, margin: 1cm)

// Create some primitives to nest
#let inner-rect = blueprint.primitive-rect(
  (0.5cm, 0.5cm),
  (1.5cm, 0.8cm),
  fill: red.lighten(80%),
  stroke: 1pt + red,
  radius: 3pt,
)

#let inner-circle = blueprint.primitive-circle(
  (3cm, 0.9cm),
  0.6cm,
  fill: blue.lighten(80%),
  stroke: 1pt + blue,
)

#let inner-ellipse = blueprint.primitive-ellipse(
  (5cm, 0.9cm),
  0.8cm, 0.5cm,
  fill: green.lighten(80%),
  stroke: 1pt + green,
)

// Test 1: Component with multiple primitive children
#let nested-comp-1 = blueprint.component(
  "nested-1",
  (inner-rect, inner-circle, inner-ellipse),
  border: true,
  border-shape: "rect",
  margin: 3mm,
  style: (
    fill: none,
    stroke: 2pt + black,
    radius: 0pt,
  ),
)
#let nested-comp-1 = blueprint.place-component(nested-comp-1, (0cm, 0cm))
#blueprint.render(nested-comp-1)

// Test 2: Component with rectangles only
#let rect1 = blueprint.primitive-rect((0.3cm, 0.3cm), (1cm, 0.6cm), fill: purple.lighten(80%), stroke: 1pt + purple)
#let rect2 = blueprint.primitive-rect((1.5cm, 0.3cm), (1cm, 0.6cm), fill: orange.lighten(80%), stroke: 1pt + orange)
#let rect3 = blueprint.primitive-rect((2.7cm, 0.3cm), (1cm, 0.6cm), fill: teal.lighten(80%), stroke: 1pt + teal)

#let nested-comp-2 = blueprint.component(
  "nested-2",
  (rect1, rect2, rect3),
  border: true,
  border-shape: "rect",
  margin: 2mm,
  style: (
    fill: gray.lighten(95%),
    stroke: 1pt + gray,
    radius: 5pt,
  ),
)
#let nested-comp-2 = blueprint.place-component(nested-comp-2, (0cm, 3cm))
#blueprint.render(nested-comp-2)

// Test 3: Component with circular border containing shapes
#let nested-comp-3 = blueprint.component(
  "nested-3",
  (
    blueprint.primitive-circle((1.2cm, 1.2cm), 0.8cm, fill: yellow.lighten(80%), stroke: 1pt + yellow),
  ),
  border: true,
  border-shape: "circle",
  margin: 3mm,
  style: (
    fill: none,
    stroke: 2pt + orange,
  ),
)
#let nested-comp-3 = blueprint.place-component(nested-comp-3, (0cm, 6cm))
#blueprint.render(nested-comp-3)

// Test 4: Component without border containing primitives
#let nested-comp-4 = blueprint.component(
  "nested-4",
  (
    blueprint.primitive-rect((0.2cm, 0.2cm), (1.2cm, 0.5cm), fill: red.lighten(90%), stroke: 1pt + red),
    blueprint.primitive-rect((0.2cm, 0.9cm), (1.2cm, 0.5cm), fill: blue.lighten(90%), stroke: 1pt + blue),
  ),
  border: false,
  margin: 0pt,
)
#let nested-comp-4 = blueprint.place-component(nested-comp-4, (4cm, 6cm))
#blueprint.render(nested-comp-4)
