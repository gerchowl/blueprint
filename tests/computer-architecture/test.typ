/// Test: Computer architecture — CPU with caches, memory controller, buses
#import "/src/exports.typ" as blueprint

#set page(width: 18cm, height: 22cm, margin: 0.5cm)

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
#let edge-cache = blueprint.edge-style("cache-bus", stroke: 1.5pt + rgb("#f9a825"), marks: "<->")

// ── CPU Core ────────────────────────────────────────────────────────
// CeTZ uses Y-up: higher Y = higher on page

#let make-core(name) = blueprint.component(
  name,
  (
    blueprint.primitive-rect((0.2cm, 0.15cm), (0.8cm, 0.5cm),
      fill: rgb("#9fa8da"), stroke: 0.8pt + rgb("#3949ab"), radius: 1pt,
      label: "ALU"),
    blueprint.primitive-rect((1.2cm, 0.15cm), (0.5cm, 0.5cm),
      fill: rgb("#7986cb"), stroke: 0.8pt + rgb("#283593"), radius: 1pt,
      label: "Regs"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: core-style,
  connectors: (
    blueprint.connector("l1-data", (0pt, 0pt), side: "bottom", offset: 0.5, style: conn-data),
    blueprint.connector("ctrl", (0pt, 0pt), side: "top", offset: 0.5, style: conn-ctrl),
  ),
)

// ── L1 Cache ────────────────────────────────────────────────────────

#let make-l1(name) = blueprint.component(
  name,
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.2cm, 0.3cm),
      fill: rgb("#fff59d"), stroke: 0.6pt + rgb("#f9a825"), radius: 1pt,
      label: "L1$"),
  ),
  border: true, border-shape: "rect", margin: 1mm, style: cache-style,
  connectors: (
    blueprint.connector("core", (0pt, 0pt), side: "top", offset: 0.5, style: conn-data),
    blueprint.connector("l2", (0pt, 0pt), side: "bottom", offset: 0.5, style: conn-data),
  ),
)

// ── L2 Cache ────────────────────────────────────────────────────────

#let l2-cache = blueprint.component(
  "L2 Cache",
  (
    blueprint.primitive-rect((0.15cm, 0.1cm), (3.7cm, 0.35cm),
      fill: rgb("#fff176"), stroke: 0.8pt + rgb("#f9a825"), radius: 1pt,
      label: "L2$"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: cache-style,
  connectors: (
    blueprint.connector("l1-a", (0pt, 0pt), side: "top", offset: 0.25, style: conn-data),
    blueprint.connector("l1-b", (0pt, 0pt), side: "top", offset: 0.75, style: conn-data),
    blueprint.connector("l3", (0pt, 0pt), side: "bottom", offset: 0.5, style: conn-data),
  ),
)

// ── L3 Cache (shared) ───────────────────────────────────────────────

#let l3-cache = blueprint.component(
  "L3 Cache",
  (
    blueprint.primitive-rect((0.15cm, 0.1cm), (6cm, 0.4cm),
      fill: rgb("#ffee58"), stroke: 1pt + rgb("#f9a825"), radius: 2pt,
      label: "L3$"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: cache-style,
  connectors: (
    blueprint.connector("l2", (0pt, 0pt), side: "top", offset: 0.5, style: conn-data),
    blueprint.connector("mem-ctrl", (0pt, 0pt), side: "bottom", offset: 0.5, style: conn-data),
  ),
)

// ── Memory Controller ───────────────────────────────────────────────

#let mem-ctrl = blueprint.component(
  "Mem Controller",
  (
    blueprint.primitive-rect((0.15cm, 0.1cm), (2.5cm, 0.4cm),
      fill: rgb("#a5d6a7"), stroke: 0.8pt + rgb("#2e7d32"), radius: 1pt,
      label: "DDR5 MC"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: mem-style,
  connectors: (
    blueprint.connector("cache", (0pt, 0pt), side: "top", offset: 0.5, style: conn-data),
    blueprint.connector("dimm-a", (0pt, 0pt), side: "bottom", offset: 0.25, style: conn-data),
    blueprint.connector("dimm-b", (0pt, 0pt), side: "bottom", offset: 0.75, style: conn-data),
  ),
)

// ── DIMM Module ─────────────────────────────────────────────────────

#let make-dimm(name, label-text) = blueprint.component(
  name,
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.8cm, 0.3cm),
      fill: rgb("#c8e6c9"), stroke: 0.6pt + rgb("#2e7d32"), radius: 1pt,
      label: label-text),
  ),
  border: true, border-shape: "rect", margin: 1mm, style: mem-style,
  connectors: (
    blueprint.connector("bus", (0pt, 0pt), side: "top", offset: 0.5, style: conn-data),
  ),
)

// ── PCIe Controller ─────────────────────────────────────────────────

#let pcie-ctrl = blueprint.component(
  "PCIe Root",
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.5cm, 0.35cm),
      fill: rgb("#ffe0b2"), stroke: 0.8pt + rgb("#e65100"), radius: 1pt,
      label: "PCIe 5.0"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: io-style,
  connectors: (
    blueprint.connector("cpu-bus", (0pt, 0pt), side: "top", offset: 0.5, style: conn-data),
    blueprint.connector("slot-1", (0pt, 0pt), side: "bottom", offset: 0.3, style: conn-data),
    blueprint.connector("slot-2", (0pt, 0pt), side: "bottom", offset: 0.7, style: conn-data),
  ),
)

// ── GPU ─────────────────────────────────────────────────────────────

#let gpu = blueprint.component(
  "GPU",
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.8cm, 0.6cm),
      fill: rgb("#ffccbc"), stroke: 0.8pt + rgb("#bf360c"), radius: 2pt,
      label: "GPU"),
  ),
  border: true, border-shape: "rect", margin: 1.5mm, style: io-style,
  connectors: (
    blueprint.connector("pcie", (0pt, 0pt), side: "top", offset: 0.5, style: conn-data),
  ),
)

// ── NIC ─────────────────────────────────────────────────────────────

#let nic = blueprint.component(
  "NIC",
  (
    blueprint.primitive-rect((0.1cm, 0.1cm), (1.2cm, 0.4cm),
      fill: rgb("#c8e6c9"), stroke: 0.6pt + rgb("#2e7d32"), radius: 1pt,
      label: "10G NIC"),
  ),
  border: true, border-shape: "rect", margin: 1mm, style: io-style,
  connectors: (
    blueprint.connector("pcie", (0pt, 0pt), side: "top", offset: 0.5, style: conn-data),
  ),
)

// ── Full CPU Assembly (Y-up: cores at top, L3 at bottom) ──────────

#let core-a = blueprint.place-component(make-core("Core 0"), (0.2cm, 3.3cm))
#let core-b = blueprint.place-component(make-core("Core 1"), (2.5cm, 3.3cm))
#let l1-a = blueprint.place-component(make-l1("L1i/d"), (0.4cm, 2.2cm))
#let l1-b = blueprint.place-component(make-l1("L1i/d"), (2.7cm, 2.2cm))
#let l2 = blueprint.place-component(l2-cache, (0cm, 1.2cm))
#let l3 = blueprint.place-component(l3-cache, (0cm, 0cm))

#let cpu = blueprint.component(
  "CPU Package",
  (core-a, core-b, l1-a, l1-b, l2, l3),
  border: true, border-shape: "rect", margin: 3mm, style: cpu-style,
  connectors: (
    blueprint.connector("mem-out", (0pt, 0pt), side: "bottom", offset: 0.5, style: conn-data),
    blueprint.connector("pcie-out", (0pt, 0pt), side: "right", offset: 0.3, style: conn-data),
  ),
)

// ── Placement positions (absolute, for the single canvas) ──────────
// CPU package
#let cpu-x = 1cm
#let cpu-y = 8cm
// Memory controller
#let mc-x = 3cm
#let mc-y = 5.5cm
// DIMMs
#let dimm-a-x = 1.5cm
#let dimm-a-y = 3.5cm
#let dimm-b-x = 5cm
#let dimm-b-y = 3.5cm
// PCIe controller
#let pcie-x = 10cm
#let pcie-y = 6cm
// GPU
#let gpu-x = 9cm
#let gpu-y = 3.5cm
// NIC
#let nic-x = 12cm
#let nic-y = 3.5cm

// ── Connector position helpers ──────────────────────────────────────
// Calculate approximate absolute position of a border-relative connector.
// translate + connector resolved position (from component bounds).

#let conn-abs(comp, translate-pos, conn-name) = {
  let (tx, ty) = translate-pos
  let conn = blueprint.get-connector(comp, conn-name)
  let (cx, cy) = conn.position
  (tx + cx, ty + cy)
}

// Pre-compute connector absolute positions for edges
// CPU connectors
#let cpu-mem-out = conn-abs(cpu, (cpu-x, cpu-y), "mem-out")
#let cpu-pcie-out = conn-abs(cpu, (cpu-x, cpu-y), "pcie-out")
// Memory controller connectors
#let mc-cache = conn-abs(mem-ctrl, (mc-x, mc-y), "cache")
#let mc-dimm-a = conn-abs(mem-ctrl, (mc-x, mc-y), "dimm-a")
#let mc-dimm-b = conn-abs(mem-ctrl, (mc-x, mc-y), "dimm-b")
// DIMM connectors
#let dimm-a-comp = make-dimm("DIMM A", "DIMM")
#let dimm-b-comp = make-dimm("DIMM B", "DIMM")
#let da-bus = conn-abs(dimm-a-comp, (dimm-a-x, dimm-a-y), "bus")
#let db-bus = conn-abs(dimm-b-comp, (dimm-b-x, dimm-b-y), "bus")
// PCIe connectors
#let pcie-cpu = conn-abs(pcie-ctrl, (pcie-x, pcie-y), "cpu-bus")
#let pcie-slot1 = conn-abs(pcie-ctrl, (pcie-x, pcie-y), "slot-1")
#let pcie-slot2 = conn-abs(pcie-ctrl, (pcie-x, pcie-y), "slot-2")
// GPU connector
#let gpu-pcie = conn-abs(gpu, (gpu-x, gpu-y), "pcie")
// NIC connector
#let nic-pcie = conn-abs(nic, (nic-x, nic-y), "pcie")

// ── Internal CPU cache-hierarchy edge positions ─────────────────────
// These edges are drawn inside the CPU's translated scope, so positions
// are relative to the CPU origin (cpu-x, cpu-y are already the scope origin).

// Core 0 bottom → L1-a top
#let core-a-l1-from = conn-abs(core-a, (0cm, 0cm), "l1-data")
#let l1-a-core-to = conn-abs(l1-a, (0cm, 0cm), "core")
// Core 1 bottom → L1-b top
#let core-b-l1-from = conn-abs(core-b, (0cm, 0cm), "l1-data")
#let l1-b-core-to = conn-abs(l1-b, (0cm, 0cm), "core")
// L1-a bottom → L2 top (l1-a port)
#let l1-a-l2-from = conn-abs(l1-a, (0cm, 0cm), "l2")
#let l2-l1a-to = conn-abs(l2-cache, (0cm, 0cm), "l1-a")
// L1-b bottom → L2 top (l1-b port)
#let l1-b-l2-from = conn-abs(l1-b, (0cm, 0cm), "l2")
#let l2-l1b-to = conn-abs(l2-cache, (0cm, 0cm), "l1-b")
// L2 bottom → L3 top
#let l2-l3-from = conn-abs(l2-cache, (0cm, 0cm), "l3")
#let l3-l2-to = conn-abs(l3-cache, (0cm, 0cm), "l2")

// ── Full system diagram (single canvas) ─────────────────────────────

#{
  blueprint.cetz.canvas({
    // CPU package at y=8cm (top of diagram)
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((cpu-x, cpu-y))
      blueprint.draw-content(cpu)

      // Internal cache hierarchy edges (local to CPU scope)
      blueprint.connect-points(core-a-l1-from, l1-a-core-to, style: edge-cache)
      blueprint.connect-points(core-b-l1-from, l1-b-core-to, style: edge-cache)
      blueprint.connect-points(l1-a-l2-from, l2-l1a-to, style: edge-cache)
      blueprint.connect-points(l1-b-l2-from, l2-l1b-to, style: edge-cache)
      blueprint.connect-points(l2-l3-from, l3-l2-to, style: edge-cache)
    })

    // Memory controller below CPU
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((mc-x, mc-y))
      blueprint.draw-content(mem-ctrl)
    })

    // DIMMs below memory controller
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((dimm-a-x, dimm-a-y))
      blueprint.draw-content(dimm-a-comp)
    })
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((dimm-b-x, dimm-b-y))
      blueprint.draw-content(dimm-b-comp)
    })

    // PCIe controller (right of memory subsystem)
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((pcie-x, pcie-y))
      blueprint.draw-content(pcie-ctrl)
    })

    // GPU below PCIe
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((gpu-x, gpu-y))
      blueprint.draw-content(gpu)
    })

    // NIC below PCIe
    blueprint.cetz.draw.scope({
      blueprint.cetz.draw.translate((nic-x, nic-y))
      blueprint.draw-content(nic)
    })

    // ── External buses / interconnects ──
    // CPU mem-out → Memory Controller cache (memory bus)
    blueprint.connect-points(cpu-mem-out, mc-cache, style: edge-mem)
    // Mem ctrl → DIMM A
    blueprint.connect-points(mc-dimm-a, da-bus, style: edge-mem)
    // Mem ctrl → DIMM B
    blueprint.connect-points(mc-dimm-b, db-bus, style: edge-mem)
    // CPU pcie-out → PCIe root cpu-bus
    blueprint.connect-points(cpu-pcie-out, pcie-cpu, style: edge-pcie)
    // PCIe → GPU
    blueprint.connect-points(pcie-slot1, gpu-pcie, style: edge-pcie)
    // PCIe → NIC
    blueprint.connect-points(pcie-slot2, nic-pcie, style: edge-pcie)
  })
}

// ── Collapsed view ──────────────────────────────────────────────────

#blueprint.render(cpu, mode: "collapsed")
