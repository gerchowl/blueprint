/// Component system for hierarchical diagrams
#import "deps.typ": cetz
#import "utils.typ": *
#import "canvas.typ": *
#import "layout.typ": *
#import "style.typ": *
#import "connector.typ": *
#import "primitives.typ": *

/// Create a component (pure function, returns a dictionary)
/// No state registration — components are plain data
#let component(name, content, origin: (center, center), internal-origin: (left, top), border: true, border-shape: "rect", margin: 2mm, style: none, connectors: (), parent: none, position: (0pt, 0pt)) = {
  let canvas-info = create-canvas(name, parent: parent, internal-origin: internal-origin)

  let content-bounds = calculate-content-bounds(content)
  let connector-bounds = calculate-connector-bounds(connectors, content-bounds)

  let final-content-bounds = (
    x: calc.min(content-bounds.x, connector-bounds.x),
    y: calc.min(content-bounds.y, connector-bounds.y),
    width: calc.max(content-bounds.x + content-bounds.width, connector-bounds.x + connector-bounds.width) - calc.min(content-bounds.x, connector-bounds.x),
    height: calc.max(content-bounds.y + content-bounds.height, connector-bounds.y + connector-bounds.height) - calc.min(content-bounds.y, connector-bounds.y),
  )

  let border-bounds = if border {
    calculate-border-bounds(final-content-bounds, margin)
  } else {
    final-content-bounds
  }

  // Resolve border-relative connectors (side/offset → actual positions)
  let resolved-connectors = resolve-border-connectors(connectors, border-bounds)

  let canvas-info = canvas-info + (bounds: border-bounds)

  (
    name: name,
    canvas: canvas-info,
    content: content,
    origin: origin,
    internal-origin: internal-origin,
    border: border,
    border-shape: border-shape,
    margin: margin,
    style: style,
    connectors: resolved-connectors,
    bounds: border-bounds,
    content-bounds: final-content-bounds,
    parent: parent,
    children: (),
    display-mode: "detailed",
    position: position,
    is-primitive: false,
  )
}

/// Extend a component (inheritance) — pure function
#let component-extend(base, new-name, overrides) = {
  let override-content = overrides.at("content", default: none)
  let new-content = if override-content != none {
    base.content + override-content
  } else {
    base.content
  }

  let override-style = overrides.at("style", default: none)
  let new-style = if override-style != none and base.style != none {
    base.style + override-style
  } else if override-style != none {
    override-style
  } else {
    base.style
  }

  let override-connectors = overrides.at("connectors", default: none)
  let new-connectors = if override-connectors != none {
    base.connectors + override-connectors
  } else {
    base.connectors
  }

  // Build merged component
  let merged = base + overrides + (
    name: new-name,
    content: new-content,
    style: new-style,
    connectors: new-connectors,
  )

  // Recalculate bounds
  let content-bounds = calculate-content-bounds(merged.content)
  let connector-bounds = calculate-connector-bounds(merged.connectors, content-bounds)
  let final-content-bounds = (
    x: calc.min(content-bounds.x, connector-bounds.x),
    y: calc.min(content-bounds.y, connector-bounds.y),
    width: calc.max(content-bounds.x + content-bounds.width, connector-bounds.x + connector-bounds.width) - calc.min(content-bounds.x, connector-bounds.x),
    height: calc.max(content-bounds.y + content-bounds.height, connector-bounds.y + connector-bounds.height) - calc.min(content-bounds.y, connector-bounds.y),
  )
  let border-bounds = if merged.border {
    calculate-border-bounds(final-content-bounds, merged.margin)
  } else {
    final-content-bounds
  }

  let resolved-connectors = resolve-border-connectors(merged.connectors, border-bounds)

  merged + (
    bounds: border-bounds,
    content-bounds: final-content-bounds,
    connectors: resolved-connectors,
    canvas: merged.canvas + (bounds: border-bounds),
  )
}

/// Create component instances with variations — pure function
/// Returns an array of components, each with instance-id and optional name suffix.
/// - base-component: the template component to replicate
/// - count: number of instances
/// - variations: dict keyed by "0", "1", ... with per-instance overrides
/// - name-fn: optional function (index) => name string for each instance
#let instance(base-component, count: 1, variations: (:), name-fn: none) = {
  let instances = ()
  for i in range(count) {
    let variation = variations.at(str(i), default: (:))
    let inst-name = if name-fn != none { (name-fn)(i) }
      else if base-component.name != none { base-component.name + " #" + str(i + 1) }
      else { none }
    let inst = base-component + variation + (
      instance-id: i,
      instance-count: count,
      is-instance: true,
      name: inst-name,
    )
    instances.push(inst)
  }
  instances
}

/// Place component at position — returns updated component dict
/// - comp: component dictionary
/// - position: (x, y) placement coordinates
/// - anchor: optional anchor override (default: comp.origin)
#let place-component(comp, position, anchor: none) = {
  let origin-anchor = if anchor != none { anchor } else { comp.origin }
  let (px, py) = if type(position) == array { position } else { (position.x, position.y) }
  let canvas-info = calculate-canvas-transform(comp.canvas, (px, py), origin-anchor)
  comp + (position: (px, py), canvas: canvas-info)
}

/// Stack components vertically or horizontally from a starting position.
/// Returns an array of placed components.
/// - items: array of (unplaced) components
/// - start: (x, y) position for the first item
/// - direction: "up", "down", "left", "right"
/// - gap: spacing between items (length or (x, y) pair)
#let stack(items, start: (0pt, 0pt), direction: "up", gap: 4mm) = {
  if items.len() == 0 { return () }
  let placed = ()
  let prev = place-component(items.at(0), start)
  placed.push(prev)

  // Map direction to anchor pairs
  let (ref-anchor, target-anchor, gap-vec) = if direction == "up" {
    ((left, top), (left, bottom), (0pt, gap))
  } else if direction == "down" {
    ((left, bottom), (left, top), (0pt, gap))
  } else if direction == "right" {
    ((right, center), (left, center), (gap, 0pt))
  } else {
    // "left"
    ((left, center), (right, center), (gap, 0pt))
  }

  for i in range(1, items.len()) {
    let item = items.at(i)
    let pos = relative-with-anchor(
      prev, ref-anchor, target-anchor,
      target-bounds: item.bounds, gap: gap-vec,
    )
    prev = place-component(item, pos)
    placed.push(prev)
  }
  placed
}

/// Arrange components in a grid from a starting position.
/// Returns an array of placed components (row-major order).
/// - items: array of (unplaced) components
/// - start: (x, y) position for the first item (bottom-left of grid)
/// - cols: number of columns
/// - gap: (col-gap, row-gap) or single value for both
#let grid(items, start: (0pt, 0pt), cols: 3, gap: 4mm) = {
  if items.len() == 0 { return () }
  let (gap-x, gap-y) = normalize-gap(gap)

  // Place first item
  let placed = ()
  let first = place-component(items.at(0), start)
  placed.push(first)

  // Track row anchors: first item of each row
  let row-start = first

  for i in range(1, items.len()) {
    let item = items.at(i)
    let col = calc.rem(i, cols)
    let prev = placed.last()

    if col == 0 {
      // New row: place above the row-start
      let pos = relative-with-anchor(
        row-start, (left, top), (left, bottom),
        target-bounds: item.bounds, gap: (0pt, gap-y),
      )
      let p = place-component(item, pos)
      placed.push(p)
      row-start = p
    } else {
      // Same row: place to the right of previous
      let pos = relative-with-anchor(
        prev, (right, center), (left, center),
        target-bounds: item.bounds, gap: (gap-x, 0pt),
      )
      placed.push(place-component(item, pos))
    }
  }
  placed
}

// -- Rendering helpers --
// Two layers:
//   draw-*  → produces CeTZ draw commands (usable inside cetz.canvas)
//   render  → wraps draw-* in cetz.canvas() to produce Typst content

/// Render a border shape (returns CeTZ draw commands)
#let render-border(comp) = {
  let bounds = comp.bounds
  let border-shape = if type(comp.border) == str { comp.border } else { comp.border-shape }
  let s = if comp.style != none { comp.style } else { (:) }

  if border-shape == "rect" {
    let border-prim = primitive-rect(
      (bounds.x, bounds.y),
      (bounds.width, bounds.height),
      fill: s.at("fill", default: none),
      stroke: s.at("stroke", default: 1pt + black),
      radius: s.at("radius", default: 0pt),
    )
    border-prim.shape
  } else if border-shape == "circle" {
    let cx = bounds.x + bounds.width / 2
    let cy = bounds.y + bounds.height / 2
    let radius = calc.min(bounds.width, bounds.height) / 2
    let border-prim = primitive-circle(
      (cx, cy),
      radius,
      fill: s.at("fill", default: none),
      stroke: s.at("stroke", default: 1pt + black),
    )
    border-prim.shape
  } else if border-shape == "ellipse" {
    let cx = bounds.x + bounds.width / 2
    let cy = bounds.y + bounds.height / 2
    let border-prim = primitive-ellipse(
      (cx, cy),
      bounds.width / 2,
      bounds.height / 2,
      fill: s.at("fill", default: none),
      stroke: s.at("stroke", default: 1pt + black),
    )
    border-prim.shape
  }
}

/// Render component name label at the top of the border (Y-up).
/// Shows "×N" badge when the component is part of an instance group.
#let render-name-label(comp, centered: false) = {
  if comp.name == none { return }
  let b = comp.bounds
  let s = if comp.style != none { comp.style } else { (:) }
  let stroke-val = s.at("stroke", default: 1pt + black)
  let label-color = if type(stroke-val) == color { stroke-val } else { stroke-val.paint }

  // Build label text with optional instance badge
  let inst-count = comp.at("instance-count", default: none)
  let label-text = if inst-count != none and inst-count > 1 {
    comp.name + " ×" + str(inst-count)
  } else {
    comp.name
  }

  if centered {
    cetz.draw.content(
      (b.x + b.width / 2, b.y + b.height / 2),
      text(size: 9pt, fill: label-color, weight: "bold", label-text),
    )
  } else {
    cetz.draw.content(
      (b.x + b.width / 2, b.y + b.height),
      text(size: 7pt, fill: label-color, weight: "bold", label-text),
      anchor: "south",
      padding: 1pt,
    )
  }
}

/// Draw a content item as CeTZ draw commands.
/// Handles primitives, nested components, and raw CeTZ draw commands.
#let draw-item(item, mode) = {
  if type(item) == dictionary {
    if item.at("is-primitive", default: false) {
      // Primitive — emit its shape
      item.shape
    } else if "is-primitive" in item {
      // Non-primitive component — recursively render its internals
      // Translate to the component's placed position so nested coords are correct
      let pos = item.at("position", default: (0pt, 0pt))
      let (px, py) = if type(pos) == array { pos } else { (0pt, 0pt) }
      cetz.draw.scope({
        cetz.draw.translate((px, py))
        if mode == "detailed" {
          if item.border {
            render-border(item)
            render-name-label(item)
          }
          for child in item.content {
            draw-item(child, mode)
          }
          for conn in item.connectors {
            render-connector(conn, item.display-mode)
          }
        } else {
          // collapsed/high-level: just border + name + connectors
          render-border(item)
          render-name-label(item, centered: true)
          for conn in item.connectors {
            render-connector(conn, mode)
          }
        }
      })
    } else if "shape" in item {
      item.shape
    } else if "render" in item {
      (item.render)(item, mode)
    }
  } else {
    item
  }
}

/// Draw component internals as CeTZ draw commands (no canvas wrapper).
/// Safe to call from inside a cetz.canvas().
#let draw-content(comp, mode: "detailed") = {
  if comp.at("is-primitive", default: false) {
    comp.shape
  } else if mode == "detailed" {
    if comp.border {
      render-border(comp)
      render-name-label(comp)
    }
    for item in comp.content {
      draw-item(item, mode)
    }
    for conn in comp.connectors {
      render-connector(conn, comp.display-mode)
    }
  } else {
    // collapsed / high-level: border + centered name
    render-border(comp)
    render-name-label(comp, centered: true)
    for conn in comp.connectors {
      render-connector(conn, mode)
    }
  }
}

/// Render component — main entry point.
/// Wraps draw commands in cetz.canvas() to produce Typst content.
#let render(comp, mode: "detailed") = {
  if comp == none {
    panic("Component is none — cannot render")
  }

  cetz.canvas({
    draw-content(comp, mode: mode)
  })
}
