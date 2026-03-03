/// Nested canvas system for hierarchical diagrams
/// Each component has its own coordinate system
#import "deps.typ": cetz
#import "utils.typ": *

/// Create canvas info for a component (pure function, no state)
#let create-canvas(name, parent: none, internal-origin: (left, top)) = {
  (
    name: name,
    parent: parent,
    internal-origin: internal-origin,
    transform: (1, 0, 0, 1, 0pt, 0pt),
    bounds: (x: 0pt, y: 0pt, width: 0pt, height: 0pt),
  )
}

/// Transform coordinates from child to parent
#let transform-to-parent(child-canvas, point) = {
  let (x, y) = point
  let (a, b, c, d, e, f) = child-canvas.transform
  (a * x + c * y + e, b * x + d * y + f)
}

/// Transform coordinates from parent to child
#let transform-to-child(parent-canvas, point) = {
  let (x, y) = point
  let (a, b, c, d, e, f) = parent-canvas.transform
  let det = a * d - b * c
  if calc.abs(det) < 1e-10 {
    panic("Cannot invert transformation matrix")
  }
  let x-prime = x - e
  let y-prime = y - f
  ((d * x-prime - c * y-prime) / det, (-b * x-prime + a * y-prime) / det)
}

/// Calculate canvas transform for a position and anchor
#let calculate-canvas-transform(canvas-info, position, origin-anchor) = {
  let (h-anchor, v-anchor) = anchor-to-offset(origin-anchor)
  let (px, py) = position
  let bounds = canvas-info.bounds
  let offset-x = -bounds.width * h-anchor
  let offset-y = -bounds.height * v-anchor
  let new-transform = (1, 0, 0, 1, px + offset-x, py + offset-y)
  canvas-info + (transform: new-transform)
}

/// Get absolute position by walking a parent chain
/// Takes a list of canvas-infos (from child to root) and a local point
#let get-absolute-position(canvas-chain, local-point) = {
  let point = local-point
  for canvas-info in canvas-chain {
    point = transform-to-parent(canvas-info, point)
  }
  point
}
