/// Component system for hierarchical diagrams
#import "@preview/cetz:0.3.2": *
#import "utils.typ": *
#import "canvas.typ": *
#import "layout.typ": *
#import "style.typ": *
#import "connector.typ": *

/// Component registry
#let component-registry = state("component-registry", (:))

/// Create a component
#let component(name, content, origin: (center, center), internal-origin: (left, top), border: true, margin: 2mm, style: none, connectors: (), parent: none) = {
  // Create canvas for component with parent reference
  let canvas-info = create-canvas(name, parent: parent, internal-origin: internal-origin)

  // Calculate content bounds
  let content-bounds = calculate-content-bounds(content)

  // Calculate connector bounds
  let connector-bounds = calculate-connector-bounds(connectors, content-bounds)

  // Combine content and connector bounds
  let final-content-bounds = (
    x: calc.min(content-bounds.x, connector-bounds.x),
    y: calc.min(content-bounds.y, connector-bounds.y),
    width: calc.max(content-bounds.x + content-bounds.width, connector-bounds.x + connector-bounds.width) - calc.min(content-bounds.x, connector-bounds.x),
    height: calc.max(content-bounds.y + content-bounds.height, connector-bounds.y + connector-bounds.height) - calc.min(content-bounds.y, connector-bounds.y),
  )

  // Calculate border bounds
  let border-bounds = if border {
    calculate-border-bounds(final-content-bounds, margin)
  } else {
    final-content-bounds
  }

  // Update canvas bounds
  canvas-registry.update(d => {
    if name in d {
      d.at(name).bounds = border-bounds
    }
    d
  })

  let comp = (
    name: name,
    canvas: canvas-info,
    content: content,
    origin: origin,
    internal-origin: internal-origin,
    border: border,
    margin: margin,
    style: style,
    connectors: connectors,
    bounds: border-bounds,
    content-bounds: final-content-bounds,
    parent: parent,
    children: (),
    display-mode: "detailed",
    position: (0pt, 0pt), // Default position
  )

  // Register component
  component-registry.update(d => {
    d.insert(name, comp)
    d
  })

  // Register object for relative positioning
  register-object(name, border-bounds, (0pt, 0pt))
  
  comp
}

/// Extend a component (inheritance)
#let component-extend(base-name, new-name, overrides) = {
  let base = component-registry.get().at(base-name, default: none)
  if base == none {
    error("Base component not found: " + str(base-name))
  }
  
  // Deep merge: combine content arrays, merge styles, etc.
  let override-content = overrides.at("content", default: none)
  let new-content = if override-content != none {
    base.content + override-content
  } else {
    base.content
  }
  
  let override-style = overrides.at("style", default: none)
  let new-style = if override-style != none {
    base.style + override-style
  } else {
    base.style
  }
  
  let override-connectors = overrides.at("connectors", default: none)
  let new-connectors = if override-connectors != none {
    base.connectors + override-connectors
  } else {
    base.connectors
  }
  
  // Merge other properties
  let merged-overrides = overrides + (
    content: new-content,
    style: new-style,
    connectors: new-connectors,
    name: new-name,
    parent: base.parent, // Inherit parent unless overridden
  )
  
  // Create new component with merged properties
  let new-comp = base + merged-overrides
  
  // Register new component
  component-registry.update(d => {
    d.insert(new-name, new-comp)
    d
  })
  
  new-comp
}

/// Place component at position
#let place-component(comp-name, position, anchor: none) = {
  let comp = component-registry.get().at(comp-name, default: none)
  if comp == none {
    error("Component not found: " + str(comp-name))
  }
  
  let origin-anchor = if anchor != none { anchor } else { comp.origin }
  let (px, py) = if type(position) == array { position } else { (position.x, position.y) }
  
  // Update component position
  component-registry.update(d => {
    if comp-name in d {
      d.at(comp-name).position = (px, py)
    }
    d
  })
  
  // Update canvas transform
  update-canvas-transform(comp-name, (px, py), origin-anchor)
  
  // Update object registry for relative positioning
  register-object(comp-name, comp.bounds, (px, py))
}

/// Create component instance
#let instance(component, count: 1, variations: (:)) = {
  let instances = ()
  for i in range(count) {
    let variation = variations.at((i,), default: (:))
    let inst = component + variation + (instance-id: i, is-instance: true)
    instances.push(inst)
  }
  instances
}

/// Render component
#let render(component, mode: "detailed") = {
  let display-mode = mode
  let comp = if type(component) == str {
    component-registry.get().at(component, default: none)
  } else {
    component
  }

  if comp == none {
    error("Component not found or invalid")
  }

  // Update display mode
  component-registry.update(d => {
    if comp.name in d {
      d.at(comp.name).display-mode = display-mode
    }
    d
  })

  // Render based on mode
  if display-mode == "detailed" {
    render-detailed(comp)
  } else if display-mode == "collapsed" {
    render-collapsed(comp)
  } else if display-mode == "high-level" {
    render-high-level(comp)
  } else {
    render-detailed(comp)
  }
}

/// Render detailed view
#let render-detailed(comp) = {
  cetz.canvas({
    // Apply canvas transformation
    cetz.set-transform(comp.canvas.transform)

    // Render all content
    for item in comp.content {
      // Render item (primitive, other component, or raw cetz)
      if type(item) == dict and "render" in item {
        item.render(item, comp.display-mode)
      } else if type(item) == dict and "shape" in item {
        // Primitive
        item.shape
      } else {
        // Assume raw cetz or primitive
        item
      }
    }

    // Render border if enabled
    if comp.border {
      let bounds = comp.bounds
      cetz.draw.rect(
        (bounds.x, bounds.y),
        (bounds.x + bounds.width, bounds.y + bounds.height),
        stroke: comp.style.at("stroke", default: 1pt + black),
        fill: comp.style.at("fill", default: none),
      )
    }

    // Render connectors
    for conn in comp.connectors {
      render-connector(conn, comp.display-mode)
    }
  })
}

/// Render collapsed view
#let render-collapsed(comp) = {
  cetz.canvas({
    cetz.set-transform(comp.canvas.transform)
    // Render as box with connectors only
    let bounds = comp.bounds
    cetz.draw.rect(
      (bounds.x, bounds.y),
      (bounds.x + bounds.width, bounds.y + bounds.height),
      stroke: comp.style.at("stroke", default: 1pt + black),
      fill: comp.style.at("fill", default: none),
    )

    // Render connectors (may be collapsed)
    for conn in comp.connectors {
      render-connector(conn, "collapsed")
    }
  })
}

/// Render high-level view
#let render-high-level(comp) = {
  cetz.canvas({
    cetz.set-transform(comp.canvas.transform)
    // Minimal representation
    let bounds = comp.bounds
    cetz.draw.rect(
      (bounds.x, bounds.y),
      (bounds.x + bounds.width, bounds.y + bounds.height),
      stroke: comp.style.at("stroke", default: 1pt + black),
      fill: comp.style.at("fill", default: none),
    )

    // Connectors shown as collapsed groups
    for conn in comp.connectors {
      render-connector(conn, "high-level")
    }
  })
}

