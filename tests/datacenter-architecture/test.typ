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
#let conn-stor = (size: 3pt, shape: "square", fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"))

#let edge-1g = blueprint.edge-style("1g-eth", stroke: 1pt + rgb("#66bb6a"), marks: "->")
#let edge-storage = blueprint.edge-style("iscsi", stroke: 1.5pt + rgb("#e65100"), marks: "<->", dash: "dashed")

// ── ToR Switch (Top of Rack) ────────────────────────────────────────
// Y-up: downlink ports at bottom, uplinks at top

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
    // Downlink ports (to servers below) -- at bottom border
    blueprint.connector("dl-1", (0pt, 0pt), side: "bottom", offset: 0.12, style: conn-eth),
    blueprint.connector("dl-2", (0pt, 0pt), side: "bottom", offset: 0.27, style: conn-eth),
    blueprint.connector("dl-3", (0pt, 0pt), side: "bottom", offset: 0.42, style: conn-eth),
    blueprint.connector("dl-4", (0pt, 0pt), side: "bottom", offset: 0.57, style: conn-eth),
    blueprint.connector("dl-stor", (0pt, 0pt), side: "bottom", offset: 0.80, style: conn-stor),
    // Uplinks (to spine switches) -- at top border
    blueprint.connector("uplink-1", (0pt, 0pt), side: "top", offset: 0.3, style: conn-eth),
    blueprint.connector("uplink-2", (0pt, 0pt), side: "top", offset: 0.7, style: conn-eth),
  ),
)

// ── 1U Server (factory function) ────────────────────────────────────

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
      // Uplink eth0 at top border, centered
      blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.5, style: conn-eth),
      // Power at left border
      blueprint.connector("pwr", (0pt, 0pt), side: "left", offset: 0.5, style: conn-pwr),
    ),
  )
}

// ── Storage Array ───────────────────────────────────────────────────

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
    // iSCSI uplink at top border, centered
    blueprint.connector("iscsi", (0pt, 0pt), side: "top", offset: 0.5, style: conn-stor),
  ),
)

// ── Rack Assembly (Y-up: switch at top, storage at bottom) ──────────

#let tor = blueprint.place-component(tor-switch, (0.3cm, 8cm))
#let srv1 = blueprint.place-component(make-server("Server 1"), (0.5cm, 6.3cm))
#let srv2 = blueprint.place-component(make-server("Server 2"), (0.5cm, 4.8cm))
#let srv3 = blueprint.place-component(make-server("Server 3"), (0.5cm, 3.3cm))
#let srv4 = blueprint.place-component(make-server("Server 4"), (0.5cm, 1.8cm))
#let stor = blueprint.place-component(storage, (0.3cm, 0.3cm))

#let rack = blueprint.component(
  "Rack 1",
  (tor, srv1, srv2, srv3, srv4, stor),
  border: true, border-shape: "rect", margin: 3mm, style: rack-style,
)

// ── Detailed view with edges (single canvas) ────────────────────────
// Connector positions are resolved relative to each child's local border,
// then offset by the child's placement position in the rack.

#{
  // Helper: get absolute position of a connector on a placed child component
  let conn-abs(child, conn-name) = {
    let pos = child.position
    let (px, py) = if type(pos) == array { pos } else { (0pt, 0pt) }
    let conn = blueprint.get-connector(child, conn-name)
    let (cx, cy) = if type(conn.position) == array { conn.position } else { (0pt, 0pt) }
    (px + cx, py + cy)
  }

  // Pre-compute connector positions for edges
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
    // Draw the entire rack (nested components rendered recursively)
    blueprint.draw-content(rack)

    // ── Edges: switch downlinks -> server eth0 uplinks ──
    blueprint.connect-points(tor-dl1, srv1-eth0, style: edge-1g)
    blueprint.connect-points(tor-dl2, srv2-eth0, style: edge-1g)
    blueprint.connect-points(tor-dl3, srv3-eth0, style: edge-1g)
    blueprint.connect-points(tor-dl4, srv4-eth0, style: edge-1g)

    // ── Edge: switch storage port -> storage iSCSI uplink ──
    blueprint.connect-points(tor-dl-stor, stor-iscsi, style: edge-storage)
  })
}

// ── Collapsed view ──────────────────────────────────────────────────

#blueprint.render(rack, mode: "collapsed")

// ── High-level view ─────────────────────────────────────────────────

#blueprint.render(rack, mode: "high-level")
