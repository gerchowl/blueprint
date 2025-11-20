/// Component system for hierarchical diagrams
#import "deps.typ": cetz
#import "utils.typ": *
#import "canvas.typ": *
#import "layout.typ": *
#import "style.typ": *
#import "connector.typ": *
#import "primitives.typ": *

/// Component registry
#let component-registry = state("component-registry", (:))

/// Create a component
#let component(name, content, origin: (center, center), internal-origin: (left, top), border: true, border-shape: "rect", margin: 2mm, style: none, connectors: (), parent: none) = {
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

  let comp = (
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
    position: (0pt, 0pt), // Default position
    is-primitive: false,
  )

  // Update canvas bounds
  canvas-registry.update(d => {
    if name in d {
      d.at(name).bounds = border-bounds
    }
    d
  })

  // Register component
  component-registry.update(d => {
    d.insert(name, comp)
    d
  })

  // Register object for relative positioning
  register-object(name, border-bounds, (0pt, 0pt))
  
  // Return dictionary - use return to avoid joining content with dictionary
  // State updates above still execute and update state, but their content is discarded
  return comp
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

/// Render detailed view
#let render-detailed(comp) = {
  // Both primitives and components need a canvas for CeTZ to render
  cetz.canvas({
    // Check if this is a primitive (simpler rendering)
    if comp.at("is-primitive", default: false) {
      // Render primitive shape directly
      comp.shape
    } else {
      // Render all content
      for item in comp.content {
        // Render item (primitive as component, other component, or raw cetz)
        if type(item) == "dictionary" and "render" in item {
          // Component or primitive (both have render function now)
          item.render(item, comp.display-mode)
        } else if type(item) == "dictionary" and "shape" in item {
          // Legacy primitive format (backward compatibility)
          item.shape
        } else {
          // Assume raw cetz
          item
        }
      }

      // Render border if enabled - using primitive functions for consistency
      if comp.border {
        let bounds = comp.bounds
        let border-shape = if type(comp.border) == str { comp.border } else { comp.border-shape }
        let style = if comp.style != none { comp.style } else { (:) }
        
        if border-shape == "rect" {
          let border-prim = primitive-rect(
            (bounds.x, bounds.y),
            (bounds.width, bounds.height),
            fill: style.at("fill", default: none),
            stroke: style.at("stroke", default: 1pt + black),
            radius: style.at("radius", default: 0pt),
          )
          border-prim.shape
        } else if border-shape == "circle" {
          let center = (bounds.x + bounds.width/2, bounds.y + bounds.height/2)
          let radius = calc.min(bounds.width, bounds.height) / 2
          let border-prim = primitive-circle(
            center,
            radius,
            fill: style.at("fill", default: none),
            stroke: style.at("stroke", default: 1pt + black),
          )
          border-prim.shape
        } else if border-shape == "ellipse" {
          let center = (bounds.x + bounds.width/2, bounds.y + bounds.height/2)
          let border-prim = primitive-ellipse(
            center,
            bounds.width / 2,
            bounds.height / 2,
            fill: style.at("fill", default: none),
            stroke: style.at("stroke", default: 1pt + black),
          )
          border-prim.shape
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
  // Primitives don't have collapsed view
  if comp.at("is-primitive", default: false) {
    comp.shape
  } else {
    cetz.canvas({
      // Render as box with connectors only - using border shape
      let bounds = comp.bounds
      let border-shape = if type(comp.border) == str { comp.border } else { comp.border-shape }
      let style = if comp.style != none { comp.style } else { (:) }
      
      if border-shape == "rect" {
        let border-prim = primitive-rect(
          (bounds.x, bounds.y),
          (bounds.width, bounds.height),
          fill: style.at("fill", default: none),
          stroke: style.at("stroke", default: 1pt + black),
          radius: style.at("radius", default: 0pt),
        )
        border-prim.shape
      } else if border-shape == "circle" {
        let center = (bounds.x + bounds.width/2, bounds.y + bounds.height/2)
        let radius = calc.min(bounds.width, bounds.height) / 2
        let border-prim = primitive-circle(
          center,
          radius,
          fill: style.at("fill", default: none),
          stroke: style.at("stroke", default: 1pt + black),
        )
        border-prim.shape
      } else if border-shape == "ellipse" {
        let center = (bounds.x + bounds.width/2, bounds.y + bounds.height/2)
        let border-prim = primitive-ellipse(
          center,
          bounds.width / 2,
          bounds.height / 2,
          fill: style.at("fill", default: none),
          stroke: style.at("stroke", default: 1pt + black),
        )
        border-prim.shape
      }

      // Render connectors (may be collapsed)
      for conn in comp.connectors {
        render-connector(conn, "collapsed")
      }
    })
  }
}

/// Render high-level view
#let render-high-level(comp) = {
  // Primitives don't have high-level view
  if comp.at("is-primitive", default: false) {
    comp.shape
  } else {
    cetz.canvas({
      // Minimal representation - using border shape
      let bounds = comp.bounds
      let border-shape = if type(comp.border) == str { comp.border } else { comp.border-shape }
      let style = if comp.style != none { comp.style } else { (:) }
      
      if border-shape == "rect" {
        let border-prim = primitive-rect(
          (bounds.x, bounds.y),
          (bounds.width, bounds.height),
          fill: style.at("fill", default: none),
          stroke: style.at("stroke", default: 1pt + black),
          radius: style.at("radius", default: 0pt),
        )
        border-prim.shape
      } else if border-shape == "circle" {
        let center = (bounds.x + bounds.width/2, bounds.y + bounds.height/2)
        let radius = calc.min(bounds.width, bounds.height) / 2
        let border-prim = primitive-circle(
          center,
          radius,
          fill: style.at("fill", default: none),
          stroke: style.at("stroke", default: 1pt + black),
        )
        border-prim.shape
      } else if border-shape == "ellipse" {
        let center = (bounds.x + bounds.width/2, bounds.y + bounds.height/2)
        let border-prim = primitive-ellipse(
          center,
          bounds.width / 2,
          bounds.height / 2,
          fill: style.at("fill", default: none),
          stroke: style.at("stroke", default: 1pt + black),
        )
        border-prim.shape
      }

      // Connectors shown as collapsed groups
      for conn in comp.connectors {
        render-connector(conn, "high-level")
      }
    })
  }
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

  // Render based on mode - use return to avoid joining content with rendering
  return if display-mode == "detailed" {
    render-detailed(comp)
  } else if display-mode == "collapsed" {
    render-collapsed(comp)
  } else if display-mode == "high-level" {
    render-high-level(comp)
  } else {
    render-detailed(comp)
  }
}

