/// Simple example: Basic component
#import "../src/lib.typ" as blueprint
#import "@preview/cetz:0.4.2": *

#set page(width: 15cm, height: 10cm, margin: 1cm)

= Simple Component Example

This example demonstrates creating a basic component with connectors.

#let cpu = blueprint.component(
  name: "cpu",
  content: (
    blueprint.primitive-rect((0pt, 0pt), (2cm, 1.5cm), fill: gray.lighten(80%)),
  ),
  connectors: (
    blueprint.connector("bus", (1cm, 0pt)),
    blueprint.connector("memory", (2cm, 0.75cm)),
  ),
)

#blueprint.place-component("cpu", (2cm, 2cm))
#blueprint.render(cpu)

