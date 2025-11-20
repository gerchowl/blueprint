/// Nested canvas system for hierarchical diagrams
/// Each component has its own coordinate system
#import "deps.typ": cetz
#import "utils.typ": *

/// Canvas registry to track nested canvases
#let canvas-registry = state("canvas-registry", (:))

/// Create a new canvas for a component
#let create-canvas(name, parent: none, internal-origin: (left, top)) = {
  let canvas = cetz.canvas({
    // Component's internal canvas
  })

  let canvas-info = (
    name: name,
    canvas: canvas,
    parent: parent,
    internal-origin: internal-origin,
    transform: (1, 0, 0, 1, 0pt, 0pt), // Identity transform initially
    bounds: (x: 0pt, y: 0pt, width: 0pt, height: 0pt),
  )

  // Update registry - use return to avoid joining content with dictionary
  // State update still executes and updates state, but content is discarded
  canvas-registry.update(d => {
    d.insert(name, canvas-info)
    d
  })
  
  return canvas-info
}

/// Get canvas by name
#let get-canvas(name) = canvas-registry.get().at(name, default: none)

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

  // Inverse transformation
  let det = a * d - b * c
  if calc.abs(det) < 1e-10 {
    error("Cannot invert transformation matrix")
  }

  let x-prime = x - e
  let y-prime = y - f

  ((d * x-prime - c * y-prime) / det, (-b * x-prime + a * y-prime) / det)
}

/// Update canvas transform based on position and origin
#let update-canvas-transform(canvas-name, position, origin-anchor) = {
  let canvas = get-canvas(canvas-name)
  if canvas == none { return }

  let (h-anchor, v-anchor) = anchor-to-offset(origin-anchor)
  let (px, py) = position

  // Calculate offset based on anchor and component bounds
  let bounds = canvas.bounds
  let offset-x = -bounds.width * h-anchor
  let offset-y = -bounds.height * v-anchor

  let new-transform = (1, 0, 0, 1, px + offset-x, py + offset-y)

  canvas-registry.update(d => {
    if canvas-name in d {
      d.at(canvas-name).transform = new-transform
    }
    d
  })
}

/// Get absolute position of a point in a canvas
#let get-absolute-position(canvas-name, local-point) = {
  let canvas = get-canvas(canvas-name)
  if canvas == none { return local-point }

  let current = canvas
  let point = local-point

  // Walk up the parent chain applying transformations
  while current.parent != none {
    point = transform-to-parent(current, point)
    current = get-canvas(current.parent)
    if current == none { break }
  }

  point
}

