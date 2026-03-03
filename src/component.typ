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
    connectors: connectors,
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

  merged + (
    bounds: border-bounds,
    content-bounds: final-content-bounds,
    canvas: merged.canvas + (bounds: border-bounds),
  )
}

/// Create component instances with variations — pure function
#let instance(base-component, count: 1, variations: (:)) = {
  let instances = ()
  for i in range(count) {
    let variation = variations.at(str(i), default: (:))
    let inst = base-component + variation + (instance-id: i, is-instance: true)
    instances.push(inst)
  }
  instances
}

/// Place component at position — returns updated component dict
#let place-component(comp, position, anchor: none) = {
  let origin-anchor = if anchor != none { anchor } else { comp.origin }
  let (px, py) = if type(position) == array { position } else { (position.x, position.y) }
  let canvas-info = calculate-canvas-transform(comp.canvas, (px, py), origin-anchor)
  comp + (position: (px, py), canvas: canvas-info)
}

// -- Rendering helpers (produce CeTZ drawing content) --

/// Render a border shape inside a CeTZ canvas
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

/// Render detailed view
#let render-detailed(comp) = {
  cetz.canvas({
    if comp.at("is-primitive", default: false) {
      comp.shape
    } else {
      // Render border first (background)
      if comp.border {
        render-border(comp)
      }

      // Render all content
      for item in comp.content {
        if type(item) == dictionary and "render" in item {
          (item.render)(item, comp.display-mode)
        } else if type(item) == dictionary and "shape" in item {
          item.shape
        } else {
          item
        }
      }

      // Render connectors
      for conn in comp.connectors {
        render-connector(conn, comp.display-mode)
      }
    }
  })
}

/// Render collapsed view
#let render-collapsed(comp) = {
  if comp.at("is-primitive", default: false) {
    cetz.canvas({ comp.shape })
  } else {
    cetz.canvas({
      render-border(comp)
      for conn in comp.connectors {
        render-connector(conn, "collapsed")
      }
    })
  }
}

/// Render high-level view
#let render-high-level(comp) = {
  if comp.at("is-primitive", default: false) {
    cetz.canvas({ comp.shape })
  } else {
    cetz.canvas({
      render-border(comp)
      for conn in comp.connectors {
        render-connector(conn, "high-level")
      }
    })
  }
}

/// Render component — main entry point
/// component: a component dict or primitive dict
/// mode: "detailed", "collapsed", or "high-level"
#let render(comp, mode: "detailed") = {
  if comp == none {
    panic("Component is none — cannot render")
  }

  if mode == "detailed" {
    render-detailed(comp)
  } else if mode == "collapsed" {
    render-collapsed(comp)
  } else if mode == "high-level" {
    render-high-level(comp)
  } else {
    render-detailed(comp)
  }
}
