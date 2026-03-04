/// Test: Edge routing and arrow marks
#import "/src/exports.typ" as blueprint

#set page(width: 16cm, height: 22cm, margin: 0.5cm)

#let man = blueprint.edge-style("man", marks: "->", routing: "manhattan")
#let man-bidi = blueprint.edge-style("man-bidi", marks: "<->", routing: "manhattan")

// ── Section 1: Mark styles (direct routing) ──────────────────────

#{
  blueprint.cetz.canvas({
    // Labels
    blueprint.cetz.draw.content((0cm, 2.8cm), text(8pt, weight: "bold", "Mark styles"), anchor: "south-west")

    // Forward arrow (->)
    blueprint.connect-points((0cm, 2cm), (3cm, 2cm),
      style: blueprint.edge-style("fwd", marks: "->"))
    blueprint.cetz.draw.content((3.2cm, 2cm), text(7pt, `-> forward`), anchor: "west")

    // Bidirectional arrow (<->)
    blueprint.connect-points((0cm, 1.3cm), (3cm, 1.3cm),
      style: blueprint.edge-style("bidi", marks: "<->"))
    blueprint.cetz.draw.content((3.2cm, 1.3cm), text(7pt, `<-> bidi`), anchor: "west")

    // No arrow (plain line)
    blueprint.connect-points((0cm, 0.6cm), (3cm, 0.6cm),
      style: blueprint.edge-style("no-arrow", marks: "-"))
    blueprint.cetz.draw.content((3.2cm, 0.6cm), text(7pt, `- no arrow`), anchor: "west")

    // Reverse arrow (<-)
    blueprint.connect-points((0cm, 0cm), (3cm, 0cm),
      style: blueprint.edge-style("rev", marks: "<-"))
    blueprint.cetz.draw.content((3.2cm, 0cm), text(7pt, `<- reverse`), anchor: "west")
  })
}

// ── Section 2: Rectangular routing ───────────────────────────────

#{
  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 2.8cm), text(8pt, weight: "bold", "Rectangular routing"), anchor: "south-west")
    blueprint.connect-points((0cm, 0cm), (3cm, 2cm),
      style: blueprint.edge-style("rect", marks: "->", routing: "rectangular"),
      routing: "rectangular")
    blueprint.cetz.draw.content((3.2cm, 1cm), text(7pt, `horizontal → vertical`), anchor: "west")
  })
}

// ── Section 3: Manhattan routing with side hints ─────────────────

// Helper: draw a small labeled box at position to represent a connector on a border
#let draw-node(pos, label-text, side) = {
  let (x, y) = pos
  let s = 2.5pt
  blueprint.cetz.draw.rect((x - s, y - s), (x + s, y + s), fill: rgb("#e3f2fd"), stroke: 0.8pt + blue)
  let anchor = if side == "top" { "north" }
    else if side == "bottom" { "south" }
    else if side == "left" { "east" }
    else { "west" }
  let label-pos = if side == "top" { (x, y - 4pt) }
    else if side == "bottom" { (x, y + 4pt) }
    else if side == "left" { (x + 4pt, y) }
    else { (x - 4pt, y) }
  blueprint.cetz.draw.content(label-pos, text(6pt, fill: blue, label-text), anchor: anchor)
}

// 3a: Opposite sides — bottom → top (vertical corridor)
#{
  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 4.5cm), text(8pt, weight: "bold", "Manhattan: opposite sides (bottom → top)"), anchor: "south-west")
    let from = (1cm, 4cm)
    let to = (4cm, 0.5cm)
    draw-node(from, "A (bottom)", "bottom")
    draw-node(to, "B (top)", "top")
    blueprint.connect-points(from, to, style: man, routing: "manhattan",
      from-side: "bottom", to-side: "top")
  })
}

// 3b: Same sides — both right
#{
  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 4.5cm), text(8pt, weight: "bold", "Manhattan: same side (right → right)"), anchor: "south-west")
    let from = (2cm, 3.5cm)
    let to = (2cm, 1cm)
    draw-node(from, "A (right)", "right")
    draw-node(to, "B (right)", "right")
    blueprint.connect-points(from, to, style: man, routing: "manhattan",
      from-side: "right", to-side: "right")
  })
}

// 3c: Adjacent sides — right → top (L-shape, 1 turn)
#{
  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 4.5cm), text(8pt, weight: "bold", "Manhattan: adjacent (right → top), 1 turn"), anchor: "south-west")
    let from = (1cm, 3cm)
    let to = (5cm, 0.5cm)
    draw-node(from, "A (right)", "right")
    draw-node(to, "B (top)", "top")
    blueprint.connect-points(from, to, style: man, routing: "manhattan",
      from-side: "right", to-side: "top")
  })
}

// 3d: Adjacent sides — bottom → left
#{
  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 4.5cm), text(8pt, weight: "bold", "Manhattan: adjacent (bottom → left), 1 turn"), anchor: "south-west")
    let from = (1.5cm, 3.5cm)
    let to = (5cm, 1cm)
    draw-node(from, "A (bottom)", "bottom")
    draw-node(to, "B (left)", "left")
    blueprint.connect-points(from, to, style: man, routing: "manhattan",
      from-side: "bottom", to-side: "left")
  })
}

// 3e: No side hints (auto heuristic)
#{
  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 4.5cm), text(8pt, weight: "bold", "Manhattan: no side hints (auto)"), anchor: "south-west")
    let from = (1cm, 1cm)
    let to = (5cm, 3.5cm)
    draw-node(from, "A", "right")
    draw-node(to, "B", "left")
    blueprint.connect-points(from, to, style: man, routing: "manhattan")
  })
}

// ── Section 4: Dashed and colored edges ──────────────────────────

#{
  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 2.2cm), text(8pt, weight: "bold", "Dashed and colored"), anchor: "south-west")

    // Dashed
    blueprint.connect-points((0cm, 1.5cm), (3cm, 1.5cm),
      style: blueprint.edge-style("dashed", stroke: 1pt + black, marks: "->", dash: "dashed"))
    blueprint.cetz.draw.content((3.2cm, 1.5cm), text(7pt, `dashed`), anchor: "west")

    // Red
    blueprint.connect-points((0cm, 0.8cm), (3cm, 0.8cm),
      style: blueprint.edge-style("red", stroke: 2pt + red, marks: "->"))
    blueprint.cetz.draw.content((3.2cm, 0.8cm), text(7pt, `red 2pt`), anchor: "west")

    // Blue bidi
    blueprint.connect-points((0cm, 0cm), (3cm, 0cm),
      style: blueprint.edge-style("blue", stroke: 2pt + blue, marks: "<->"))
    blueprint.cetz.draw.content((3.2cm, 0cm), text(7pt, `blue bidi`), anchor: "west")
  })
}

// ── Section 5: Manhattan with components ─────────────────────────

#{
  let box-style = (fill: rgb("#e8f5e9"), stroke: 1.5pt + rgb("#2e7d32"), radius: 3pt)
  let conn-s = (size: 3pt, shape: "square", fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"))

  let comp-a = blueprint.component("CompA",
    (blueprint.primitive-rect((0.2cm, 0.15cm), (1.2cm, 0.5cm),
      fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), label: "Module A"),),
    border: true, border-shape: "rect", margin: 1.5mm, style: box-style,
    connectors: (
      blueprint.connector("out-r", (0pt, 0pt), side: "right", offset: 0.5, style: conn-s),
      blueprint.connector("out-b", (0pt, 0pt), side: "bottom", offset: 0.5, style: conn-s),
    ),
  )

  let comp-b = blueprint.component("CompB",
    (blueprint.primitive-rect((0.2cm, 0.15cm), (1.2cm, 0.5cm),
      fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), label: "Module B"),),
    border: true, border-shape: "rect", margin: 1.5mm, style: box-style,
    connectors: (
      blueprint.connector("in-l", (0pt, 0pt), side: "left", offset: 0.5, style: conn-s),
      blueprint.connector("in-t", (0pt, 0pt), side: "top", offset: 0.5, style: conn-s),
    ),
  )

  let a = blueprint.place-component(comp-a, (0.5cm, 2.5cm))
  let b = blueprint.place-component(comp-b, (5cm, 0.5cm))

  let parent = blueprint.component("", (a, b), border: false, margin: 0mm)

  // Helper for absolute connector positions
  let conn-abs(comp, conn-name) = {
    let pos = comp.position
    let (px, py) = if type(pos) == array { pos } else { (0pt, 0pt) }
    let conn = blueprint.get-connector(comp, conn-name)
    let (cx, cy) = if type(conn.position) == array { conn.position } else { (0pt, 0pt) }
    (px + cx, py + cy, conn)
  }

  let (ax, ay, a-out-r) = conn-abs(a, "out-r")
  let (bx, by, b-in-l) = conn-abs(b, "in-l")
  let (ax2, ay2, a-out-b) = conn-abs(a, "out-b")
  let (bx2, by2, b-in-t) = conn-abs(b, "in-t")

  let man-green = blueprint.edge-style("man-green", stroke: 1.5pt + rgb("#2e7d32"), marks: "->", routing: "manhattan")

  blueprint.cetz.canvas({
    blueprint.cetz.draw.content((0cm, 5cm), text(8pt, weight: "bold", "Manhattan with components"), anchor: "south-west")
    blueprint.draw-content(parent)

    // Right → Left (horizontal exit, horizontal entry — L-shape)
    blueprint.connect-points((ax, ay), (bx, by), style: man-green, routing: "manhattan",
      from-side: "right", to-side: "left")

    // Bottom → Top (vertical exit, vertical entry — bridge with 2 turns)
    blueprint.connect-points((ax2, ay2), (bx2, by2),
      style: blueprint.edge-style("man-orange", stroke: 1.5pt + rgb("#e65100"), marks: "<->", routing: "manhattan", dash: "dashed"),
      routing: "manhattan", from-side: "bottom", to-side: "top")
  })
}
