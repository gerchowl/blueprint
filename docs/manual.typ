/// Blueprint Manual
/// 
/// Comprehensive documentation for the Blueprint hierarchical diagram package

#import "@preview/tidy:0.4.3"
#import "../src/lib.typ" as blueprint
#import "@preview/cetz:0.4.2": *

#set page(paper: "a4", margin: 2cm)
#set text(size: 11pt, font: "Linux Libertine")

#let VERSION = toml("../typst.toml").package.version

// Cover page
#v(10%)

#align(center)[
  #stack(
    spacing: 17pt,
    {
      #text(size: 3.2em, weight: "bold")[Blueprint]
      #text(size: 1.5em)[Hierarchical Diagram Package]
    },
    [Version #VERSION],
  )
  
  #v(30pt)
  
  A #link("https://typst.app/")[Typst] package for creating hierarchical
  technical component diagrams with nested components, built directly on
  #link("https://cetz-package.github.io")[CeTZ].
  
  #emph[
    Component diagrams,
    flow charts,
    system architectures,
    technical blueprints...
  ]
]

#v(1fr)

// Table of contents
#outline(
  title: [Manual],
  target: heading,
  depth: 3,
)

#pagebreak()

// Introduction
= Introduction

Blueprint is a comprehensive Typst package for creating hierarchical technical
diagrams. It provides a powerful system for building nested component diagrams
with flexible styling, positioning, and connection capabilities.

== Features

- *Nested Components*: Create components with their own coordinate systems
- *Multiple Rendering Modes*: Detailed, collapsed, and high-level views
- *Component Inheritance*: Extend and customize components
- *Connector System*: Grouped and individual connectors with flexible display
- *Edge Routing*: Direct, rectangular, Manhattan, and manual routing
- *Reusable Styles*: Define and apply styles to components, connectors, and edges
- *Flexible Positioning*: Absolute and relative positioning with anchor points

// API Reference
= API Reference

== Components

#let module-docs(name) = {
  [== #raw(name)]
  
  let path = "../src/" + name + ".typ"
  let docs = tidy.parse-module(read(path),
    label-prefix: "blueprint.",
    scope: blueprint,
  )
  set raw(lang: "typc")
  tidy.show-module(
    docs,
    style: dictionary(tidy.styles.default) + (
      show-reference: (label, name, style-args: none) => {
        name = name.split(".").last()
        link(label, raw(name, lang: none))
      },
      show-example: (..args) => {
        tidy.styles.default.show-example(..args, ratio: 1.5)
      }
    )
  )
}

#module-docs("component")
#pagebreak()
#module-docs("connector")
#pagebreak()
#module-docs("edge")
#pagebreak()
#module-docs("primitives")
#pagebreak()
#module-docs("layout")
#pagebreak()
#module-docs("style")

