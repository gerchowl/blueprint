/// Test: Datacenter rack architecture with servers, switches, and cabling
#import "/src/exports.typ" as blueprint

#set page(width: 18cm, height: 16cm, margin: 0.5cm)

// ── Styles ──────────────────────────────────────────────────────────

#let switch-style = (fill: rgb("#e8f5e9"), stroke: 2pt + rgb("#2e7d32"), radius: 3pt)
#let server-style = (fill: rgb("#e3f2fd"), stroke: 1.5pt + rgb("#1565c0"), radius: 2pt)
#let storage-style = (fill: rgb("#fff3e0"), stroke: 1.5pt + rgb("#e65100"), radius: 2pt)
#let rack-style = (fill: rgb("#fafafa"), stroke: 2pt + black, radius: 4pt)

#let conn-eth = (size: 3pt, shape: "square", fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"))
#let conn-pwr = (size: 3pt, shape: "square", fill: rgb("#ffcdd2"), stroke: 0.8pt + rgb("#c62828"))

#let edge-1g = blueprint.edge-style("1g-eth", stroke: 1pt + rgb("#66bb6a"), marks: "->")
#let edge-storage = blueprint.edge-style("iscsi", stroke: 1.5pt + rgb("#e65100"), marks: "<->", dash: "dashed")

// ── ToR Switch (Top of Rack) ────────────────────────────────────────
// Y-up: downlink ports at bottom (low Y), uplinks at top (high Y)

#let tor-switch = blueprint.component(
  "tor-switch",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (5.6cm, 0.5cm),
      fill: rgb("#a5d6a7"), stroke: 0.8pt + rgb("#2e7d32"), radius: 2pt),
  ),
  border: true, border-shape: "rect", margin: 2mm, style: switch-style,
  connectors: (
    // Downlink ports (to servers below) — at bottom in Y-up
    blueprint.connector("port-1", (1cm, 0cm), style: conn-eth),
    blueprint.connector("port-2", (2cm, 0cm), style: conn-eth),
    blueprint.connector("port-3", (3cm, 0cm), style: conn-eth),
    blueprint.connector("port-4", (4cm, 0cm), style: conn-eth),
    blueprint.connector("port-5", (5cm, 0cm), style: conn-eth),
    // Uplinks (to spine) — at top in Y-up
    blueprint.connector("uplink-1", (0cm, 0.9cm), style: conn-eth),
    blueprint.connector("uplink-2", (6cm, 0.9cm), style: conn-eth),
  ),
)

// ── 1U Server ───────────────────────────────────────────────────────

#let make-server(name) = {
  blueprint.component(
    name,
    (
      // CPU
      blueprint.primitive-rect((0.2cm, 0.15cm), (1cm, 0.4cm),
        fill: rgb("#bbdefb"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt),
      // RAM
      blueprint.primitive-rect((1.4cm, 0.15cm), (0.6cm, 0.4cm),
        fill: rgb("#b3e5fc"), stroke: 0.8pt + rgb("#0277bd"), radius: 1pt),
      // NIC
      blueprint.primitive-rect((2.2cm, 0.15cm), (0.5cm, 0.4cm),
        fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt),
    ),
    border: true, border-shape: "rect", margin: 1.5mm, style: server-style,
    connectors: (
      blueprint.connector("eth0", (1.5cm, 0.7cm), style: conn-eth),
      blueprint.connector("pwr", (0cm, 0.35cm), style: conn-pwr),
    ),
  )
}

// ── Storage Array ───────────────────────────────────────────────────

#let storage = blueprint.component(
  "storage-array",
  (
    // Disk bays
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt),
    blueprint.primitive-rect((1.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt),
    blueprint.primitive-rect((2.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 2mm, style: storage-style,
  connectors: (
    blueprint.connector("iscsi", (2.2cm, 0.9cm), style: conn-eth),
  ),
)

// ── Rack Assembly (Y-up: switch at top, storage at bottom) ──────────

#let tor = blueprint.place-component(tor-switch, (0.3cm, 8cm))
#let srv1 = blueprint.place-component(make-server("srv-1"), (0.5cm, 6.3cm))
#let srv2 = blueprint.place-component(make-server("srv-2"), (0.5cm, 4.8cm))
#let srv3 = blueprint.place-component(make-server("srv-3"), (0.5cm, 3.3cm))
#let srv4 = blueprint.place-component(make-server("srv-4"), (0.5cm, 1.8cm))
#let stor = blueprint.place-component(storage, (0.3cm, 0.3cm))

#let rack = blueprint.component(
  "rack-1",
  (tor, srv1, srv2, srv3, srv4, stor),
  border: true, border-shape: "rect", margin: 3mm, style: rack-style,
)

// ── Full rack with edges (single canvas) ────────────────────────────

#{
  blueprint.cetz.canvas({
    // Draw the entire rack (nested components rendered recursively)
    blueprint.draw-content(rack)

    // ── Edges: switch downlinks to server eth0 ──
    // ToR at (0.3, 8) + port local y=0 → downlink ports near y=8
    // Server at (0.5, Y) + eth0 local (1.5, 0.7) → eth0 near y=Y+0.7
    blueprint.connect-points((1.3cm, 8cm), (2cm, 7cm), style: edge-1g)
    blueprint.connect-points((2.3cm, 8cm), (2cm, 5.5cm), style: edge-1g)
    blueprint.connect-points((3.3cm, 8cm), (2cm, 4cm), style: edge-1g)
    blueprint.connect-points((4.3cm, 8cm), (2cm, 2.5cm), style: edge-1g)
    // Storage iSCSI
    blueprint.connect-points((5.3cm, 8cm), (2.5cm, 1.2cm), style: edge-storage)
  })
}

// ── Collapsed view ──────────────────────────────────────────────────

#blueprint.render(rack, mode: "collapsed")

// ── High-level view ─────────────────────────────────────────────────

#blueprint.render(rack, mode: "high-level")
