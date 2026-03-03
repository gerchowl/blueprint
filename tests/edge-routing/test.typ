/// Test: Edge routing and arrow marks
#import "/src/exports.typ" as blueprint

#set page(width: 14cm, height: 10cm, margin: 1cm)

// --- Direct routing with different mark styles ---

// Forward arrow (->)
#{
  blueprint.cetz.canvas({
    blueprint.connect-points(
      (0cm, 0cm), (3cm, 0cm),
      style: blueprint.edge-style("direct-arrow", marks: "->"),
    )
  })
}

// Bidirectional arrow (<->)
#{
  blueprint.cetz.canvas({
    blueprint.connect-points(
      (0cm, 1.5cm), (3cm, 1.5cm),
      style: blueprint.edge-style("bidi", marks: "<->"),
    )
  })
}

// No arrow (plain line)
#{
  blueprint.cetz.canvas({
    blueprint.connect-points(
      (0cm, 3cm), (3cm, 3cm),
      style: blueprint.edge-style("no-arrow", marks: "-"),
    )
  })
}

// Reverse arrow (<-)
#{
  blueprint.cetz.canvas({
    blueprint.connect-points(
      (0cm, 4.5cm), (3cm, 4.5cm),
      style: blueprint.edge-style("reverse", marks: "<-"),
    )
  })
}

// --- Routing modes ---

// Rectangular routing (horizontal then vertical)
#{
  blueprint.cetz.canvas({
    blueprint.connect-points(
      (5cm, 0cm), (8cm, 2cm),
      style: blueprint.edge-style("rect-route", marks: "->", routing: "rectangular"),
      routing: "rectangular",
    )
  })
}

// Manhattan routing (smart rectangular based on distance)
#{
  blueprint.cetz.canvas({
    blueprint.connect-points(
      (5cm, 3cm), (8cm, 5cm),
      style: blueprint.edge-style("manhattan", marks: "->", routing: "manhattan"),
      routing: "manhattan",
    )
  })
}

// --- Dashed edge ---
#{
  blueprint.cetz.canvas({
    blueprint.connect-points(
      (0cm, 6cm), (3cm, 6cm),
      style: blueprint.edge-style("dashed-edge", stroke: 1pt + black, marks: "->", dash: "dashed"),
    )
  })
}

// --- Colored edges ---
#{
  blueprint.cetz.canvas({
    // Red forward arrow
    blueprint.connect-points(
      (0cm, 7.5cm), (3cm, 7.5cm),
      style: blueprint.edge-style("red-edge", stroke: 2pt + red, marks: "->"),
    )
    // Blue bidirectional arrow
    blueprint.connect-points(
      (5cm, 7.5cm), (8cm, 7.5cm),
      style: blueprint.edge-style("blue-edge", stroke: 2pt + blue, marks: "<->"),
    )
  })
}
