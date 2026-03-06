/// Test: Relative positioning — same datacenter rack built with relative placement
/// instead of hardcoded absolute coordinates
#import "/src/exports.typ" as blueprint

#set page(width: 18cm, height: 16cm, margin: 0.5cm)

// ── Styles ──────────────────────────────────────────────────────────

#let switch-style = (fill: rgb("#e8f5e9"), stroke: 2pt + rgb("#2e7d32"), radius: 3pt)
#let server-style = (fill: rgb("#e3f2fd"), stroke: 1.5pt + rgb("#1565c0"), radius: 2pt)
#let storage-style = (fill: rgb("#fff3e0"), stroke: 1.5pt + rgb("#e65100"), radius: 2pt)
#let rack-style = (fill: rgb("#fafafa"), stroke: 2pt + black, radius: 4pt)

#let conn-eth = (size: 3pt, shape: "square", fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"))
#let conn-pwr = (size: 3pt, shape: "square", fill: rgb("#ffcdd2"), stroke: 0.8pt + rgb("#c62828"))
#let conn-stor = (size: 3pt, shape: "square", fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"))

#let edge-1g = blueprint.edge-style("1g-eth", stroke: 1pt + rgb("#66bb6a"), marks: "->")
#let edge-storage = blueprint.edge-style("iscsi", stroke: 1.5pt + rgb("#e65100"), marks: "<->", dash: "dashed")

// ── Component definitions (same as datacenter test) ─────────────────

#let tor-switch = blueprint.component(
  "ToR Switch",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (2.5cm, 0.5cm),
      fill: rgb("#a5d6a7"), stroke: 0.8pt + rgb("#2e7d32"), radius: 2pt,
      label: "24x 10GbE"),
    blueprint.primitive-rect((3.0cm, 0.15cm), (2.5cm, 0.5cm),
      fill: rgb("#81c784"), stroke: 0.8pt + rgb("#2e7d32"), radius: 2pt,
      label: "24x 1GbE"),
  ),
  border: true, border-shape: "rect", margin: 2mm, style: switch-style,
  connectors: (
    blueprint.connector("dl-1", (0pt, 0pt), side: "bottom", offset: 0.12, style: conn-eth),
    blueprint.connector("dl-2", (0pt, 0pt), side: "bottom", offset: 0.27, style: conn-eth),
    blueprint.connector("dl-3", (0pt, 0pt), side: "bottom", offset: 0.42, style: conn-eth),
    blueprint.connector("dl-4", (0pt, 0pt), side: "bottom", offset: 0.57, style: conn-eth),
    blueprint.connector("dl-stor", (0pt, 0pt), side: "bottom", offset: 0.80, style: conn-stor),
    blueprint.connector("uplink-1", (0pt, 0pt), side: "top", offset: 0.3, style: conn-eth),
    blueprint.connector("uplink-2", (0pt, 0pt), side: "top", offset: 0.7, style: conn-eth),
  ),
)

#let make-server(name) = {
  blueprint.component(
    name,
    (
      blueprint.primitive-rect((0.2cm, 0.15cm), (1cm, 0.4cm),
        fill: rgb("#bbdefb"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt,
        label: "CPU"),
      blueprint.primitive-rect((1.4cm, 0.15cm), (0.6cm, 0.4cm),
        fill: rgb("#b3e5fc"), stroke: 0.8pt + rgb("#0277bd"), radius: 1pt,
        label: "RAM"),
      blueprint.primitive-rect((2.2cm, 0.15cm), (0.5cm, 0.4cm),
        fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt,
        label: "NIC"),
    ),
    border: true, border-shape: "rect", margin: 1.5mm, style: server-style,
    connectors: (
      blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.5, style: conn-eth),
      blueprint.connector("pwr", (0pt, 0pt), side: "left", offset: 0.5, style: conn-pwr),
    ),
  )
}

#let storage = blueprint.component(
  "Storage Array",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt,
      label: "Disk 1"),
    blueprint.primitive-rect((1.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt,
      label: "Disk 2"),
    blueprint.primitive-rect((2.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt,
      label: "Disk 3"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt,
      label: "Disk 4"),
  ),
  border: true, border-shape: "rect", margin: 2mm, style: storage-style,
  connectors: (
    blueprint.connector("iscsi", (0pt, 0pt), side: "top", offset: 0.5, style: conn-stor),
  ),
)

// ── RELATIVE PLACEMENT ──────────────────────────────────────────────
// Instead of hardcoded positions, we place components relative to each other.
// Start with storage at bottom, then stack servers above it, switch on top.
// Uses left-aligned stacking to keep components aligned on the left edge.

// Vertical-only gap between components (x=0, y=5mm)
#let v-gap = (0pt, 5mm)

// 1. Place storage at the bottom of the rack (only this is absolute)
#let stor = blueprint.place-component(storage, (0.3cm, 0.3cm))

// 2. Stack servers above storage using relative positioning
//    (left, top) → (left, bottom): align left edges, place target's bottom at ref's top + gap
#let srv4-pos = blueprint.relative-with-anchor(
  stor, (left, top), (left, bottom),
  target-bounds: make-server("").bounds, gap: v-gap,
)
#let srv4 = blueprint.place-component(make-server("Server 4"), srv4-pos)

#let srv3-pos = blueprint.relative-with-anchor(
  srv4, (left, top), (left, bottom),
  target-bounds: make-server("").bounds, gap: v-gap,
)
#let srv3 = blueprint.place-component(make-server("Server 3"), srv3-pos)

#let srv2-pos = blueprint.relative-with-anchor(
  srv3, (left, top), (left, bottom),
  target-bounds: make-server("").bounds, gap: v-gap,
)
#let srv2 = blueprint.place-component(make-server("Server 2"), srv2-pos)

#let srv1-pos = blueprint.relative-with-anchor(
  srv2, (left, top), (left, bottom),
  target-bounds: make-server("").bounds, gap: v-gap,
)
#let srv1 = blueprint.place-component(make-server("Server 1"), srv1-pos)

// 3. Place switch above server 1 (also left-aligned)
#let tor-pos = blueprint.relative-with-anchor(
  srv1, (left, top), (left, bottom),
  target-bounds: tor-switch.bounds, gap: v-gap,
)
#let tor = blueprint.place-component(tor-switch, tor-pos)

// ── Assemble into rack ──────────────────────────────────────────────

#let rack = blueprint.component(
  "Rack 1 (Relative)",
  (tor, srv1, srv2, srv3, srv4, stor),
  border: true, border-shape: "rect", margin: 3mm, style: rack-style,
)

// ── Detailed view with edges ────────────────────────────────────────

#{
  let conn-abs(child, conn-name) = {
    let pos = child.position
    let (px, py) = if type(pos) == array { pos } else { (0pt, 0pt) }
    let conn = blueprint.get-connector(child, conn-name)
    let (cx, cy) = if type(conn.position) == array { conn.position } else { (0pt, 0pt) }
    (px + cx, py + cy)
  }

  let tor-dl1 = conn-abs(tor, "dl-1")
  let tor-dl2 = conn-abs(tor, "dl-2")
  let tor-dl3 = conn-abs(tor, "dl-3")
  let tor-dl4 = conn-abs(tor, "dl-4")
  let tor-dl-stor = conn-abs(tor, "dl-stor")

  let srv1-eth0 = conn-abs(srv1, "eth0")
  let srv2-eth0 = conn-abs(srv2, "eth0")
  let srv3-eth0 = conn-abs(srv3, "eth0")
  let srv4-eth0 = conn-abs(srv4, "eth0")
  let stor-iscsi = conn-abs(stor, "iscsi")

  blueprint.cetz.canvas({
    blueprint.draw-content(rack)

    blueprint.connect-points(tor-dl1, srv1-eth0, style: edge-1g)
    blueprint.connect-points(tor-dl2, srv2-eth0, style: edge-1g)
    blueprint.connect-points(tor-dl3, srv3-eth0, style: edge-1g)
    blueprint.connect-points(tor-dl4, srv4-eth0, style: edge-1g)

    blueprint.connect-points(tor-dl-stor, stor-iscsi, style: edge-storage)
  })
}

// ── Collapsed view ──────────────────────────────────────────────────

#blueprint.render(rack, mode: "collapsed")

// ── High-level view ─────────────────────────────────────────────────

#blueprint.render(rack, mode: "high-level")
