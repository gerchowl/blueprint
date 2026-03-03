/// Edge system with styles and routing
#import "deps.typ": cetz
#import "utils.typ": *
#import "style.typ": *
#import "connector.typ": get-connector, calculate-connector-position

/// Define an edge style (pure function, returns a dict)
#let edge-style(name, stroke: 1pt + black, marks: "->", routing: "direct", dash: none, decorations: none) = {
  (
    name: name,
    stroke: stroke,
    marks: marks,
    routing: routing,
    dash: dash,
    decorations: decorations,
  )
}

/// Route edge directly (straight line)
#let route-direct(from, to) = {
  (from, to)
}

/// Route edge rectangularly (only horizontal/vertical)
#let route-rectangular(from, to) = {
  let (fx, fy) = from
  let (tx, ty) = to
  ((fx, fy), (tx, fy), (tx, ty))
}

/// Route edge with Manhattan routing (smart rectangular)
#let route-manhattan(from, to) = {
  let (fx, fy) = from
  let (tx, ty) = to
  let dx = calc.abs(tx - fx)
  let dy = calc.abs(ty - fy)

  if dx > dy {
    ((fx, fy), (tx, fy), (tx, ty))
  } else {
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
      panic("Manual routing requires waypoints")
    }
    route-manual(waypoints)
  } else {
    route-direct(from, to)
  }
}

/// Draw an arrowhead at a point facing a direction
/// to: the tip of the arrow
/// from: the point the arrow is coming from (used to compute direction)
/// size: arrowhead size
/// stroke-style: stroke for the arrowhead
#let draw-arrowhead(from, to, size: 6pt, fill: black, stroke-style: none) = {
  let (fx, fy) = from
  let (tx, ty) = to
  // Convert to pt floats to allow multiplication
  let dx = (tx - fx) / 1pt
  let dy = (ty - fy) / 1pt
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }

  // Unit direction vector (towards tip)
  let ux = dx / len
  let uy = dy / len

  // Perpendicular vector
  let px = -uy
  let py = ux

  // Arrow tip is at (tx, ty)
  let half = (size / 1pt) * 0.4
  let sz = size / 1pt
  let base-x = tx - ux * sz * 1pt
  let base-y = ty - uy * sz * 1pt

  let p1 = (base-x + px * half * 1pt, base-y + py * half * 1pt)
  let p2 = (base-x - px * half * 1pt, base-y - py * half * 1pt)

  cetz.draw.line(p1, (tx, ty), p2, close: true, fill: fill, stroke: stroke-style)
}

/// Parse marks string to determine start/end arrow types
/// Supports: "->", "<-", "<->", "-", "-->"
#let parse-marks(marks) = {
  if marks == none or marks == "-" or marks == "" {
    (start: false, end: false)
  } else if marks == "->" or marks == "-->" {
    (start: false, end: true)
  } else if marks == "<-" or marks == "<--" {
    (start: true, end: false)
  } else if marks == "<->" or marks == "<-->" {
    (start: true, end: true)
  } else {
    (start: false, end: true) // default to forward arrow
  }
}

/// Draw edge with style (produces CeTZ drawing commands)
#let draw-edge(vertices, style) = {
  let stroke-style = style.at("stroke", default: 1pt + black)
  let marks = style.at("marks", default: "->")
  let dash = style.at("dash", default: none)
  let mark-info = parse-marks(marks)

  // Build the effective stroke (with dash if specified)
  let effective-stroke = if dash != none {
    stroke(paint: stroke-style.paint, thickness: stroke-style.thickness, dash: dash)
  } else {
    stroke-style
  }

  // Draw the line segments
  if vertices.len() == 2 {
    let (from, to) = vertices
    cetz.draw.line(from, to, stroke: effective-stroke)
  } else if vertices.len() > 2 {
    for i in range(vertices.len() - 1) {
      let from = vertices.at(i)
      let to = vertices.at(i + 1)
      cetz.draw.line(from, to, stroke: effective-stroke)
    }
  }

  // Draw arrowheads
  if vertices.len() >= 2 {
    // Extract paint color from stroke for arrowhead fill
    let arrow-color = stroke-style.paint

    if mark-info.end {
      let last = vertices.at(vertices.len() - 1)
      let second-last = vertices.at(vertices.len() - 2)
      draw-arrowhead(second-last, last, fill: arrow-color)
    }

    if mark-info.start {
      let first = vertices.at(0)
      let second = vertices.at(1)
      draw-arrowhead(second, first, fill: arrow-color)
    }
  }
}

/// Connect two points with an edge
#let connect-points(from, to, style: none, routing: "direct", waypoints: none) = {
  let edge-s = if style != none {
    style
  } else {
    (stroke: 1pt + black, marks: "->", routing: "direct")
  }

  let routing-type = if routing == "auto" {
    edge-s.at("routing", default: "direct")
  } else {
    routing
  }

  let vertices = route-edge(from, to, routing-type, waypoints: waypoints)
  draw-edge(vertices, edge-s)
}

/// Connect two connectors or positions
#let connect(from-ref, to-ref, style: none, routing: "auto", waypoints: none) = {
  let from-pos = if type(from-ref) == dictionary {
    from-ref.at("position", default: (0pt, 0pt))
  } else if type(from-ref) == array {
    from-ref
  } else {
    (0pt, 0pt)
  }

  let to-pos = if type(to-ref) == dictionary {
    to-ref.at("position", default: (0pt, 0pt))
  } else if type(to-ref) == array {
    to-ref
  } else {
    (0pt, 0pt)
  }

  connect-points(from-pos, to-pos, style: style, routing: routing, waypoints: waypoints)
}

/// Connect to primitive anchor point
#let connect-to-anchor(primitive, anchor-name, to, style: none, routing: "direct") = {
  let anchor-pos = (primitive.get-anchor)(anchor-name)
  connect-points(anchor-pos, to, style: style, routing: routing)
}
