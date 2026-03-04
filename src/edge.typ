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

/// Route edge with Manhattan routing (smart rectangular with perpendicular border exits)
/// from-side/to-side: "top", "bottom", "left", "right" or none
/// When side info is provided, edges leave/arrive perpendicular to the border.
/// Favors fewer turns over shorter paths.
#let route-manhattan(from, to, from-side: none, to-side: none, stub: 4mm) = {
  let (fx, fy) = from
  let (tx, ty) = to

  // Determine exit direction from connector side (perpendicular outward)
  let exit-dir = if from-side == "top" { (0pt, 1pt) }
    else if from-side == "bottom" { (0pt, -1pt) }
    else if from-side == "left" { (-1pt, 0pt) }
    else if from-side == "right" { (1pt, 0pt) }
    else { none }

  // Determine entry direction (perpendicular outward from to-side, used for stub)
  let entry-dir = if to-side == "top" { (0pt, 1pt) }
    else if to-side == "bottom" { (0pt, -1pt) }
    else if to-side == "left" { (-1pt, 0pt) }
    else if to-side == "right" { (1pt, 0pt) }
    else { none }

  // If no side info, fall back to simple heuristic
  if exit-dir == none and entry-dir == none {
    // Infer directions from geometry
    let dx = tx - fx
    let dy = ty - fy
    if calc.abs(dx) < 0.5pt and calc.abs(dy) < 0.5pt {
      return (from, to)
    }
    // Prefer the direction with greater distance (fewer turns = 1 L-shape)
    if calc.abs(dx) > calc.abs(dy) {
      return ((fx, fy), (tx, fy), (tx, ty))
    } else {
      return ((fx, fy), (fx, ty), (tx, ty))
    }
  }

  // Compute exit stub point
  let (ex, ey) = if exit-dir != none {
    let (dx, dy) = exit-dir
    (fx + dx / 1pt * stub, fy + dy / 1pt * stub)
  } else { (fx, fy) }

  // Compute entry stub point
  let (nx, ny) = if entry-dir != none {
    let (dx, dy) = entry-dir
    (tx + dx / 1pt * stub, ty + dy / 1pt * stub)
  } else { (tx, ty) }

  // Determine if exit/entry are vertical or horizontal movements
  let exit-vertical = exit-dir != none and exit-dir.at(0) == 0pt
  let entry-vertical = entry-dir != none and entry-dir.at(0) == 0pt

  // Connect the two stub points with minimal turns
  let mid-points = if calc.abs(ex - nx) < 0.5pt and calc.abs(ey - ny) < 0.5pt {
    // Stubs already meet — no mid points needed
    ()
  } else if calc.abs(ex - nx) < 0.5pt {
    // Same X — straight vertical (0 extra turns)
    ()
  } else if calc.abs(ey - ny) < 0.5pt {
    // Same Y — straight horizontal (0 extra turns)
    ()
  } else if exit-vertical and entry-vertical {
    // Both stubs are vertical → need horizontal bridge (2 extra turns)
    let mid-y = (ey + ny) / 2
    ((ex, mid-y), (nx, mid-y))
  } else if not exit-vertical and not entry-vertical {
    // Both stubs are horizontal → need vertical bridge (2 extra turns)
    let mid-x = (ex + nx) / 2
    ((mid-x, ey), (mid-x, ny))
  } else if exit-vertical and not entry-vertical {
    // Exit vertical, entry horizontal → L-shape (1 extra turn)
    // Go to (ex, ny) — extend vertical to entry's Y, then horizontal
    ((ex, ny),)
  } else {
    // Exit horizontal, entry vertical → L-shape (1 extra turn)
    // Go to (nx, ey) — extend horizontal to entry's X, then vertical
    ((nx, ey),)
  }

  // Assemble path: from → exit-stub → midpoints → entry-stub → to
  let path = (from,)
  if exit-dir != none { path.push((ex, ey)) }
  for p in mid-points { path.push(p) }
  if entry-dir != none { path.push((nx, ny)) }
  path.push(to)

  // Remove redundant collinear points
  let cleaned = (path.at(0),)
  for i in range(1, path.len() - 1) {
    let (px, py) = path.at(i - 1)
    let (cx, cy) = path.at(i)
    let (nx2, ny2) = path.at(i + 1)
    // Keep point if it's a turn (not collinear)
    let same-x = calc.abs(px - cx) < 0.5pt and calc.abs(cx - nx2) < 0.5pt
    let same-y = calc.abs(py - cy) < 0.5pt and calc.abs(cy - ny2) < 0.5pt
    if not same-x and not same-y {
      cleaned.push((cx, cy))
    }
  }
  cleaned.push(path.last())
  cleaned
}

/// Route edge manually with waypoints
#let route-manual(waypoints) = {
  waypoints
}

/// Route edge based on routing type
#let route-edge(from, to, routing-type, waypoints: none, from-side: none, to-side: none) = {
  if routing-type == "direct" {
    route-direct(from, to)
  } else if routing-type == "rectangular" {
    route-rectangular(from, to)
  } else if routing-type == "manhattan" {
    route-manhattan(from, to, from-side: from-side, to-side: to-side)
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
/// from-side/to-side: optional connector side hints for Manhattan routing
#let connect-points(from, to, style: none, routing: "direct", waypoints: none, from-side: none, to-side: none) = {
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

  let vertices = route-edge(from, to, routing-type, waypoints: waypoints, from-side: from-side, to-side: to-side)
  draw-edge(vertices, edge-s)
}

/// Connect two connectors or positions
/// Auto-detects connector side for Manhattan routing when refs are connector dicts
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

  // Auto-detect side from connector dicts
  let from-side = if type(from-ref) == dictionary { from-ref.at("side", default: none) } else { none }
  let to-side = if type(to-ref) == dictionary { to-ref.at("side", default: none) } else { none }

  connect-points(from-pos, to-pos, style: style, routing: routing, waypoints: waypoints, from-side: from-side, to-side: to-side)
}

/// Connect to primitive anchor point
#let connect-to-anchor(primitive, anchor-name, to, style: none, routing: "direct") = {
  let anchor-pos = (primitive.get-anchor)(anchor-name)
  connect-points(anchor-pos, to, style: style, routing: routing)
}
