/// Edge system with styles and routing
#import "deps.typ": cetz
#import "utils.typ": *
#import "style.typ": *
#import "connector.typ": get-connector, calculate-connector-position
#import "canvas.typ": get-absolute-position

/// Import component-registry
#let component-registry = state("component-registry", (:))

/// Edge style registry
#let edge-style-registry = state("edge-style-registry", (:))

/// Define an edge style
#let edge-style(name, stroke: 1pt + black, marks: "->", routing: "direct", dash: none, decorations: none) = {
  let style = (
    name: name,
    stroke: stroke,
    marks: marks,
    routing: routing,
    dash: dash,
    decorations: decorations,
  )

  edge-style-registry.update(d => {
    d.insert(name, style)
    d
  })

  style
}

/// Get edge style by name
#let get-edge-style(name) = edge-style-registry.get().at(name, default: none)

/// Route edge directly (straight line)
#let route-direct(from, to) = {
  (from, to)
}

/// Route edge rectangularly (only horizontal/vertical)
#let route-rectangular(from, to) = {
  let (fx, fy) = from
  let (tx, ty) = to

  // Simple L-shaped routing: go horizontal first, then vertical
  let mid-x = tx
  let mid-y = fy

  ((fx, fy), (mid-x, mid-y), (tx, ty))
}

/// Route edge with Manhattan routing (smart rectangular)
#let route-manhattan(from, to) = {
  let (fx, fy) = from
  let (tx, ty) = to

  // Choose better L-shape based on distance
  let dx = calc.abs(tx - fx)
  let dy = calc.abs(ty - fy)

  if dx > dy {
    // Go horizontal first
    ((fx, fy), (tx, fy), (tx, ty))
  } else {
    // Go vertical first
    ((fx, fy), (fx, ty), (tx, ty))
  }
}

/// Route edge manually with waypoints
#let route-manual(waypoints) = {
  waypoints
}

/// Route edge based on routing type
#let route-edge(from, to, routing-type, waypoints: none) = {
  if routing-type == "direct" {
    route-direct(from, to)
  } else if routing-type == "rectangular" {
    route-rectangular(from, to)
  } else if routing-type == "manhattan" {
    route-manhattan(from, to)
  } else if routing-type == "manual" {
    if waypoints == none {
      error("Manual routing requires waypoints")
    }
    route-manual(waypoints)
  } else {
    route-direct(from, to)
  }
}

/// Draw edge with style
#let draw-edge(vertices, style) = {
  let stroke = style.at("stroke", default: 1pt + black)
  let marks = style.at("marks", default: "->")
  let dash = style.at("dash", default: none)
  let decorations = style.at("decorations", default: none)

  if vertices.len() == 2 {
    // Simple line
    let (from, to) = vertices
    cetz.draw.line(from, to, stroke: stroke, dash: dash)

    // Add marks/arrows
    if marks != none {
      // TODO: Add arrowhead rendering
    }
  } else {
    // Polyline
    for i in range(vertices.len() - 1) {
      let from = vertices.at(i)
      let to = vertices.at(i + 1)
      cetz.draw.line(from, to, stroke: stroke, dash: dash)
    }

    // Add marks
    if marks != none {
      // TODO: Add arrowhead rendering at end
    }
  }
}

/// Connect two points with an edge
#let connect-points(from, to, style-name: none, routing: "auto", waypoints: none) = {
  let style = if style-name != none {
    get-edge-style(style-name)
  } else {
    (stroke: 1pt + black, marks: "->", routing: "direct")
  }

  if style == none {
    error("Edge style not found: " + str(style-name))
  }

  let routing-type = if routing == "auto" {
    style.at("routing", default: "direct")
  } else {
    routing
  }

  let vertices = route-edge(from, to, routing-type, waypoints: waypoints)
  draw-edge(vertices, style)
}

/// Connect two connectors
/// Supports: connect(component.connector(name, index), other.connector(name), style)
#let connect(from-connector, to-connector, style-name: none, routing: "auto", waypoints: none) = {
  // Resolve connector positions
  // Connectors can be passed as:
  // - Dict with position
  // - Component reference like comp.connector("name", index)
  // - String reference like "component.connector.name"

  let from-pos = if type(from-connector) == dict {
    from-connector.at("position", default: (0, 0))
  } else if type(from-connector) == str {
    // Parse string reference "component.connector.name" or "component.connector.name[index]"
    resolve-connector-reference(from-connector)
  } else {
    (0, 0) // Placeholder
  }

  let to-pos = if type(to-connector) == dict {
    to-connector.at("position", default: (0, 0))
  } else if type(to-connector) == str {
    resolve-connector-reference(to-connector)
  } else {
    (0, 0) // Placeholder
  }

  connect-points(from-pos, to-pos, style-name: style-name, routing: routing, waypoints: waypoints)
}

/// Resolve connector reference string
#let resolve-connector-reference(ref-str) = {
  // Format: "component.connector.name" or "component.connector.name[index]"
  let parts = ref-str.split(".")
  if parts.len() < 3 {
    error("Invalid connector reference: " + ref-str)
  }

  let comp-name = parts.at(0)
  let conn-name = parts.at(2)
  let index = none

  // Check for index in connector name
  if "[" in conn-name {
    let (name-part, index-part) = conn-name.split("[")
    conn-name = name-part
    index = int(index-part.replace("]", ""))
  }

  let conn = get-connector(comp-name, conn-name, index: index)
  // Get absolute position of the connector
  let comp = component-registry.get().at(comp-name)
  get-absolute-position(comp.canvas.name, conn.position)
}

/// Connect to primitive anchor point
#let connect-to-anchor(primitive, anchor-name, to, style-name: none, routing: "auto") = {
  let anchor-pos = primitive.get-anchor(anchor-name)
  connect-points(anchor-pos, to, style-name: style-name, routing: routing)
}

