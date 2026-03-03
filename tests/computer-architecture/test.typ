/// Test: Computer architecture — CPU with caches, memory controller, buses
#import "/src/exports.typ" as blueprint

#set page(width: 16cm, height: 20cm, margin: 0.5cm)

// ── Styles ──────────────────────────────────────────────────────────

#let cpu-style = (fill: rgb("#e8eaf6"), stroke: 2pt + rgb("#283593"), radius: 4pt)
#let core-style = (fill: rgb("#c5cae9"), stroke: 1.5pt + rgb("#3949ab"), radius: 2pt)
#let cache-style = (fill: rgb("#fff9c4"), stroke: 1pt + rgb("#f9a825"), radius: 2pt)
#let mem-style = (fill: rgb("#e8f5e9"), stroke: 1.5pt + rgb("#2e7d32"), radius: 2pt)
#let io-style = (fill: rgb("#fff3e0"), stroke: 1.5pt + rgb("#e65100"), radius: 2pt)

#let conn-data = (size: 2.5pt, shape: "square", fill: rgb("#bbdefb"), stroke: 0.6pt + rgb("#1565c0"))
#let conn-ctrl = (size: 2pt, shape: "circle", fill: rgb("#ffcdd2"), stroke: 0.6pt + rgb("#c62828"))

#let edge-mem = blueprint.edge-style("mem-bus", stroke: 2pt + rgb("#2e7d32"), marks: "<->")
#let edge-pcie = blueprint.edge-style("pcie", stroke: 2.5pt + rgb("#e65100"), marks: "<->")

// ── CPU Core ────────────────────────────────────────────────────────
// CeTZ uses Y-up: higher Y = higher on page

#let make-core(name) = blueprint.component(
  name,
  (
    // ALU
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#9fa8da"), stroke: 0.8pt + rgb("#3949ab"), radius: 1pt),
    // Registers
    blueprint.primitive-rect((1.2cm, 0.15cm), (0.5cm, 0.5cm),
      fill: rgb("#7986cb"), stroke: 0.8pt + rgb("#283593"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: core-style,
  connectors: (
    blueprint.connector("l1-data", (0.9cm, 0cm), style: conn-data),
    blueprint.connector("ctrl", (0.5cm, 0.8cm), style: conn-ctrl),
  ),
)

// ── L1 Cache ────────────────────────────────────────────────────────

#let make-l1(name) = blueprint.component(
  name,
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.2cm, 0.3cm),
      fill: rgb("#fff59d"), stroke: 0.6pt + rgb("#f9a825"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 1mm, style: cache-style,
  connectors: (
    blueprint.connector("core", (0.7cm, 0.5cm), style: conn-data),
    blueprint.connector("l2", (0.7cm, 0cm), style: conn-data),
  ),
)

// ── L2 Cache ────────────────────────────────────────────────────────

#let l2-cache = blueprint.component(
  "l2-cache",
  (
    blueprint.primitive-rect((0.15cm, 0.1cm), (3.7cm, 0.35cm),
      fill: rgb("#fff176"), stroke: 0.8pt + rgb("#f9a825"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: cache-style,
  connectors: (
    blueprint.connector("l1-a", (1cm, 0.55cm), style: conn-data),
    blueprint.connector("l1-b", (3cm, 0.55cm), style: conn-data),
    blueprint.connector("l3", (2cm, 0cm), style: conn-data),
  ),
)

// ── L3 Cache (shared) ───────────────────────────────────────────────

#let l3-cache = blueprint.component(
  "l3-cache",
  (
    blueprint.primitive-rect((0.15cm, 0.1cm), (6cm, 0.4cm),
      fill: rgb("#ffee58"), stroke: 1pt + rgb("#f9a825"), radius: 2pt),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: cache-style,
  connectors: (
    blueprint.connector("l2", (3.2cm, 0.6cm), style: conn-data),
    blueprint.connector("mem-ctrl", (3.2cm, 0cm), style: conn-data),
  ),
)

// ── Memory Controller ───────────────────────────────────────────────

#let mem-ctrl = blueprint.component(
  "mem-controller",
  (
    blueprint.primitive-rect((0.15cm, 0.1cm), (2.5cm, 0.4cm),
      fill: rgb("#a5d6a7"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: mem-style,
  connectors: (
    blueprint.connector("cache", (1.4cm, 0.6cm), style: conn-data),
    blueprint.connector("dimm-a", (0.5cm, 0cm), style: conn-data),
    blueprint.connector("dimm-b", (2.3cm, 0cm), style: conn-data),
  ),
)

// ── DIMM Module ─────────────────────────────────────────────────────

#let make-dimm(name) = blueprint.component(
  name,
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.8cm, 0.3cm),
      fill: rgb("#c8e6c9"), stroke: 0.6pt + rgb("#2e7d32"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 1mm, style: mem-style,
  connectors: (
    blueprint.connector("bus", (1cm, 0.5cm), style: conn-data),
  ),
)

// ── PCIe Controller ─────────────────────────────────────────────────

#let pcie-ctrl = blueprint.component(
  "pcie-root",
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.5cm, 0.35cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: io-style,
  connectors: (
    blueprint.connector("cpu-bus", (0.85cm, 0.55cm), style: conn-data),
    blueprint.connector("slot-1", (0.5cm, 0cm), style: conn-data),
    blueprint.connector("slot-2", (1.3cm, 0cm), style: conn-data),
  ),
)

// ── GPU ─────────────────────────────────────────────────────────────

#let gpu = blueprint.component(
  "gpu",
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.8cm, 0.6cm),
      fill: rgb("#ffccbc"), stroke: 0.8pt + rgb("#bf360c"), radius: 2pt),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: io-style,
  connectors: (
    blueprint.connector("pcie", (1cm, 0.8cm), style: conn-data),
  ),
)

// ── NIC ─────────────────────────────────────────────────────────────

#let nic = blueprint.component(
  "nic",
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.2cm, 0.4cm),
      fill: rgb("#c8e6c9"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt),
  ),
  border: true, border-shape: "rect", margin: 1mm, style: io-style,
  connectors: (
    blueprint.connector("pcie", (0.7cm, 0.6cm), style: conn-data),
  ),
)

// ── Full CPU Assembly (Y-up: cores at top, L3 at bottom) ──────────

#let core-a = blueprint.place-component(make-core("core-0"), (0.2cm, 3.3cm))
#let core-b = blueprint.place-component(make-core("core-1"), (2.5cm, 3.3cm))
#let l1-a = blueprint.place-component(make-l1("l1-0"), (0.4cm, 2.2cm))
#let l1-b = blueprint.place-component(make-l1("l1-1"), (2.7cm, 2.2cm))
#let l2 = blueprint.place-component(l2-cache, (0cm, 1.2cm))
#let l3 = blueprint.place-component(l3-cache, (0cm, 0cm))

#let cpu = blueprint.component(
  "cpu-package",
  (core-a, core-b, l1-a, l1-b, l2, l3),
  border: true, border-shape: "rect", margin: 3mm, style: cpu-style,
)

// ── Full system diagram (single canvas) ─────────────────────────────

#{
  blueprint.cetz.canvas({
    // CPU package at y=8cm (top of diagram)
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((1cm, 8cm))
      blueprint.draw-content(cpu)
    })

    // Memory controller below CPU
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((3cm, 5.5cm))
      blueprint.draw-content(mem-ctrl)
    })

    // DIMMs below memory controller
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((1.5cm, 3.5cm))
      blueprint.draw-content(make-dimm("dimm-a"))
    })
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((5cm, 3.5cm))
      blueprint.draw-content(make-dimm("dimm-b"))
    })

    // PCIe controller (right of memory subsystem)
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((10cm, 6cm))
      blueprint.draw-content(pcie-ctrl)
    })

    // GPU below PCIe
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((9cm, 3.5cm))
      blueprint.draw-content(gpu)
    })

    // NIC below PCIe
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((12cm, 3.5cm))
      blueprint.draw-content(nic)
    })

    // ── Buses / interconnects ──
    // L3 → Memory Controller
    blueprint.connect-points((4.2cm, 8cm), (4.4cm, 6.6cm), style: edge-mem)
    // Mem ctrl → DIMMs
    blueprint.connect-points((3.5cm, 5.5cm), (2.5cm, 4.5cm), style: edge-mem)
    blueprint.connect-points((5.3cm, 5.5cm), (6cm, 4.5cm), style: edge-mem)
    // CPU → PCIe root
    blueprint.connect-points((8cm, 9cm), (10.8cm, 6.6cm), style: edge-pcie)
    // PCIe → GPU
    blueprint.connect-points((10.5cm, 6cm), (10cm, 4.5cm), style: edge-pcie)
    // PCIe → NIC
    blueprint.connect-points((11.3cm, 6cm), (12.7cm, 4.5cm), style: edge-pcie)
  })
}

// ── Collapsed view ──────────────────────────────────────────────────

#blueprint.render(cpu, mode: "collapsed")
