/// Auto-generated from SQLite database by sql_to_blueprint.py
#import "/src/exports.typ" as blueprint

#set page(width: 22cm, height: 32cm, margin: 0.5cm)

// ── Connector styles ──────────────────────────────────────────────

#let conn-eth = (size: 2.5pt, shape: "square", fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"))
#let conn-uplink = (size: 3pt, shape: "square", fill: rgb("#bbdefb"), stroke: 0.8pt + rgb("#1565c0"))

// ── Helper ────────────────────────────────────────────────────────

#let conn-abs(child, conn-name) = {
  let pos = child.position
  let (px, py) = if type(pos) == array { pos } else { (0pt, 0pt) }
  let c = blueprint.get-connector(child, conn-name)
  let (cx, cy) = if type(c.position) == array { c.position } else { (0pt, 0pt) }
  (px + cx, py + cy)
}

// ── Component definitions (from DB) ──────────────────────────────

#let tor-a1 = blueprint.component(
  "ToR-A1 (Arista 7050X)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (2.5cm, 0.5cm),
      fill: rgb("#e8f5e9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 2pt,
      label: "48x 10GbE"),
  ),
  border: true, border-shape: "rect", margin: 2mm,
  style: (fill: rgb("#e8f5e9"), stroke: 2pt + rgb("#2e7d32"), radius: 3pt),
  connectors: (
    blueprint.connector("uplink", (0pt, 0pt), side: "top", offset: 0.5, style: conn-uplink),
    blueprint.connector("dl-1", (0pt, 0pt), side: "bottom", offset: 0.2, style: conn-eth),
    blueprint.connector("dl-2", (0pt, 0pt), side: "bottom", offset: 0.4, style: conn-eth),
    blueprint.connector("dl-3", (0pt, 0pt), side: "bottom", offset: 0.6, style: conn-eth),
    blueprint.connector("dl-4", (0pt, 0pt), side: "bottom", offset: 0.8, style: conn-eth),
  ),
)

#let db-01 = blueprint.component(
  "db-01 (compute)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "64c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "512G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "10G"),
    blueprint.primitive-rect((2.6cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "25G"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "nvme"),
    blueprint.primitive-rect((3.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "nvme"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#e3f2fd"), stroke: 1.5pt + rgb("#1565c0"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.33, style: conn-eth),
    blueprint.connector("eth1", (0pt, 0pt), side: "top", offset: 0.67, style: conn-eth),
  ),
)

#let web-01 = blueprint.component(
  "web-01 (compute)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "32c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "256G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "10G"),
    blueprint.primitive-rect((2.6cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "10G"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "ssd"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#e3f2fd"), stroke: 1.5pt + rgb("#1565c0"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.33, style: conn-eth),
    blueprint.connector("eth1", (0pt, 0pt), side: "top", offset: 0.67, style: conn-eth),
  ),
)

#let web-02 = blueprint.component(
  "web-02 (compute)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "32c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "256G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "10G"),
    blueprint.primitive-rect((2.6cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "10G"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "ssd"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#e3f2fd"), stroke: 1.5pt + rgb("#1565c0"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.33, style: conn-eth),
    blueprint.connector("eth1", (0pt, 0pt), side: "top", offset: 0.67, style: conn-eth),
  ),
)

#let tor-a2 = blueprint.component(
  "ToR-A2 (Arista 7050X)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (2.5cm, 0.5cm),
      fill: rgb("#e8f5e9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 2pt,
      label: "48x 10GbE"),
  ),
  border: true, border-shape: "rect", margin: 2mm,
  style: (fill: rgb("#e8f5e9"), stroke: 2pt + rgb("#2e7d32"), radius: 3pt),
  connectors: (
    blueprint.connector("uplink", (0pt, 0pt), side: "top", offset: 0.5, style: conn-uplink),
    blueprint.connector("dl-1", (0pt, 0pt), side: "bottom", offset: 0.2, style: conn-eth),
    blueprint.connector("dl-2", (0pt, 0pt), side: "bottom", offset: 0.4, style: conn-eth),
    blueprint.connector("dl-3", (0pt, 0pt), side: "bottom", offset: 0.6, style: conn-eth),
    blueprint.connector("dl-4", (0pt, 0pt), side: "bottom", offset: 0.8, style: conn-eth),
  ),
)

#let stor-01 = blueprint.component(
  "stor-01 (storage)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "32c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "128G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "25G"),
    blueprint.primitive-rect((2.6cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "25G"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
    blueprint.primitive-rect((3.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
    blueprint.primitive-rect((4.5cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
    blueprint.primitive-rect((5.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#fff3e0"), stroke: 1.5pt + rgb("#e65100"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.33, style: conn-eth),
    blueprint.connector("eth1", (0pt, 0pt), side: "top", offset: 0.67, style: conn-eth),
  ),
)

#let stor-02 = blueprint.component(
  "stor-02 (storage)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "32c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "128G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "25G"),
    blueprint.primitive-rect((2.6cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "25G"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
    blueprint.primitive-rect((3.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
    blueprint.primitive-rect((4.5cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
    blueprint.primitive-rect((5.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "hdd"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#fff3e0"), stroke: 1.5pt + rgb("#e65100"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.33, style: conn-eth),
    blueprint.connector("eth1", (0pt, 0pt), side: "top", offset: 0.67, style: conn-eth),
  ),
)

#let spine-b1 = blueprint.component(
  "Spine-B1 (Arista 7500R)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (2.5cm, 0.5cm),
      fill: rgb("#e1f5fe"), stroke: 0.8pt + rgb("#01579b"), radius: 2pt,
      label: "32x 40GbE"),
  ),
  border: true, border-shape: "rect", margin: 2mm,
  style: (fill: rgb("#e1f5fe"), stroke: 2pt + rgb("#01579b"), radius: 3pt),
  connectors: (
    blueprint.connector("uplink", (0pt, 0pt), side: "top", offset: 0.5, style: conn-uplink),
    blueprint.connector("dl-1", (0pt, 0pt), side: "bottom", offset: 0.2, style: conn-eth),
    blueprint.connector("dl-2", (0pt, 0pt), side: "bottom", offset: 0.4, style: conn-eth),
    blueprint.connector("dl-3", (0pt, 0pt), side: "bottom", offset: 0.6, style: conn-eth),
    blueprint.connector("dl-4", (0pt, 0pt), side: "bottom", offset: 0.8, style: conn-eth),
  ),
)

#let mgmt-01 = blueprint.component(
  "mgmt-01 (compute)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "16c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#e3f2fd"), stroke: 0.8pt + rgb("#1565c0"), radius: 1pt, label: "64G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "10G"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#e3f2fd"), stroke: 1.5pt + rgb("#1565c0"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.50, style: conn-eth),
  ),
)

#let tor-w1 = blueprint.component(
  "ToR-W1 (Cisco 9336C)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (2.5cm, 0.5cm),
      fill: rgb("#e8f5e9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 2pt,
      label: "36x 25GbE"),
  ),
  border: true, border-shape: "rect", margin: 2mm,
  style: (fill: rgb("#e8f5e9"), stroke: 2pt + rgb("#2e7d32"), radius: 3pt),
  connectors: (
    blueprint.connector("uplink", (0pt, 0pt), side: "top", offset: 0.5, style: conn-uplink),
    blueprint.connector("dl-1", (0pt, 0pt), side: "bottom", offset: 0.2, style: conn-eth),
    blueprint.connector("dl-2", (0pt, 0pt), side: "bottom", offset: 0.4, style: conn-eth),
    blueprint.connector("dl-3", (0pt, 0pt), side: "bottom", offset: 0.6, style: conn-eth),
    blueprint.connector("dl-4", (0pt, 0pt), side: "bottom", offset: 0.8, style: conn-eth),
  ),
)

#let gpu-01 = blueprint.component(
  "gpu-01 (gpu)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#fce4ec"), stroke: 0.8pt + rgb("#880e4f"), radius: 1pt, label: "96c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#fce4ec"), stroke: 0.8pt + rgb("#880e4f"), radius: 1pt, label: "1024G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "100G"),
    blueprint.primitive-rect((2.6cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "100G"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "nvme"),
    blueprint.primitive-rect((3.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "nvme"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#fce4ec"), stroke: 1.5pt + rgb("#880e4f"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.33, style: conn-eth),
    blueprint.connector("eth1", (0pt, 0pt), side: "top", offset: 0.67, style: conn-eth),
  ),
)

#let gpu-02 = blueprint.component(
  "gpu-02 (gpu)",
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.7cm, 0.4cm), fill: rgb("#fce4ec"), stroke: 0.8pt + rgb("#880e4f"), radius: 1pt, label: "96c"),
    blueprint.primitive-rect((1.1cm, 0.15cm), (0.6cm, 0.4cm), fill: rgb("#fce4ec"), stroke: 0.8pt + rgb("#880e4f"), radius: 1pt, label: "1024G"),
    blueprint.primitive-rect((1.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "100G"),
    blueprint.primitive-rect((2.6cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt, label: "100G"),
    blueprint.primitive-rect((3.2cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "nvme"),
    blueprint.primitive-rect((3.9cm, 0.15cm), (0.5cm, 0.4cm), fill: rgb("#fff3e0"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt, label: "nvme"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm,
  style: (fill: rgb("#fce4ec"), stroke: 1.5pt + rgb("#880e4f"), radius: 2pt),
  connectors: (
    blueprint.connector("eth0", (0pt, 0pt), side: "top", offset: 0.33, style: conn-eth),
    blueprint.connector("eth1", (0pt, 0pt), side: "top", offset: 0.67, style: conn-eth),
  ),
)

// ── Rack assemblies (relative positioning) ───────────────────────

// ── Rack-A1 assembly (using stack combinator) ──
#let rack-a1-items = blueprint.stack(
  (web-02, web-01, db-01, tor-a1,),
  start: (0.3cm, 0.3cm), direction: "up", gap: 4mm,
)
#let rack-a1-web-02 = rack-a1-items.at(0)
#let rack-a1-web-01 = rack-a1-items.at(1)
#let rack-a1-db-01 = rack-a1-items.at(2)
#let rack-a1-tor-a1 = rack-a1-items.at(3)

#let rack-a1 = blueprint.component(
  "Rack-A1",
  (..rack-a1-items,),
  border: true, border-shape: "rect", margin: 3mm,
  style: (fill: rgb("#fafafa"), stroke: 2pt + black, radius: 4pt),
)

// ── Rack-A2 assembly (using stack combinator) ──
#let rack-a2-items = blueprint.stack(
  (stor-02, stor-01, tor-a2,),
  start: (0.3cm, 0.3cm), direction: "up", gap: 4mm,
)
#let rack-a2-stor-02 = rack-a2-items.at(0)
#let rack-a2-stor-01 = rack-a2-items.at(1)
#let rack-a2-tor-a2 = rack-a2-items.at(2)

#let rack-a2 = blueprint.component(
  "Rack-A2",
  (..rack-a2-items,),
  border: true, border-shape: "rect", margin: 3mm,
  style: (fill: rgb("#fafafa"), stroke: 2pt + black, radius: 4pt),
)

// ── Rack-B1 assembly (using stack combinator) ──
#let rack-b1-items = blueprint.stack(
  (mgmt-01, spine-b1,),
  start: (0.3cm, 0.3cm), direction: "up", gap: 4mm,
)
#let rack-b1-mgmt-01 = rack-b1-items.at(0)
#let rack-b1-spine-b1 = rack-b1-items.at(1)

#let rack-b1 = blueprint.component(
  "Rack-B1",
  (..rack-b1-items,),
  border: true, border-shape: "rect", margin: 3mm,
  style: (fill: rgb("#fafafa"), stroke: 2pt + black, radius: 4pt),
)

// ── Rack-W1 assembly (using stack combinator) ──
#let rack-w1-items = blueprint.stack(
  (gpu-02, gpu-01, tor-w1,),
  start: (0.3cm, 0.3cm), direction: "up", gap: 4mm,
)
#let rack-w1-gpu-02 = rack-w1-items.at(0)
#let rack-w1-gpu-01 = rack-w1-items.at(1)
#let rack-w1-tor-w1 = rack-w1-items.at(2)

#let rack-w1 = blueprint.component(
  "Rack-W1",
  (..rack-w1-items,),
  border: true, border-shape: "rect", margin: 3mm,
  style: (fill: rgb("#fafafa"), stroke: 2pt + black, radius: 4pt),
)

// ── DC-East (Virginia, US) ── Detailed views ──────

// Rack-A1 — detailed with edges
#{
  blueprint.cetz.canvas({
    blueprint.draw-content(rack-a1)
  // Edges for Rack-A1
  blueprint.connect-points(conn-abs(rack-a1-tor-a1, "dl-1"), conn-abs(rack-a1-web-01, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#66bb6a"), marks: "->", label: "10G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  blueprint.connect-points(conn-abs(rack-a1-tor-a1, "dl-2"), conn-abs(rack-a1-web-02, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#66bb6a"), marks: "->", label: "10G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  blueprint.connect-points(conn-abs(rack-a1-tor-a1, "dl-3"), conn-abs(rack-a1-db-01, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#66bb6a"), marks: "->", label: "10G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  })
}

// Rack-A2 — detailed with edges
#{
  blueprint.cetz.canvas({
    blueprint.draw-content(rack-a2)
  // Edges for Rack-A2
  blueprint.connect-points(conn-abs(rack-a2-tor-a2, "dl-1"), conn-abs(rack-a2-stor-01, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#ff9800"), marks: "->", label: "25G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  blueprint.connect-points(conn-abs(rack-a2-tor-a2, "dl-2"), conn-abs(rack-a2-stor-02, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#ff9800"), marks: "->", label: "25G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  })
}

// Rack-B1 — detailed with edges
#{
  blueprint.cetz.canvas({
    blueprint.draw-content(rack-b1)
  // Edges for Rack-B1
  blueprint.connect-points(conn-abs(rack-b1-spine-b1, "dl-1"), conn-abs(rack-b1-mgmt-01, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#66bb6a"), marks: "->", label: "10G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  })
}

// ── DC-West (Oregon, US) ── Detailed views ──────

// Rack-W1 — detailed with edges
#{
  blueprint.cetz.canvas({
    blueprint.draw-content(rack-w1)
  // Edges for Rack-W1
  blueprint.connect-points(conn-abs(rack-w1-tor-w1, "dl-1"), conn-abs(rack-w1-gpu-01, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#e53935"), marks: "->", label: "100G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  blueprint.connect-points(conn-abs(rack-w1-tor-w1, "dl-2"), conn-abs(rack-w1-gpu-02, "eth0"), style: blueprint.edge-style("", stroke: 1pt + rgb("#e53935"), marks: "->", label: "100G"), routing: "manhattan", from-side: "bottom", to-side: "top")
  })
}

// ── Collapsed views ──────────────────────────────────────────────

#blueprint.render(rack-a1, mode: "collapsed")
#blueprint.render(rack-a2, mode: "collapsed")
#blueprint.render(rack-b1, mode: "collapsed")
#blueprint.render(rack-w1, mode: "collapsed")
