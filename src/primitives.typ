/// Standard drawing primitives with anchor points
/// Primitives are minimal components (name: none, content: ())
#import "deps.typ": cetz
#import "utils.typ": *

/// Create a minimal component (for primitives)
/// This creates a component-like structure without state registration
#let create-minimal-component(bounds, shape, anchors-dict, get-anchor-fn) = {
  (
    name: none,
    canvas: (
      name: none,
      parent: none,
      internal-origin: (left, top),
      transform: (1, 0, 0, 1, 0pt, 0pt),
      bounds: bounds,
    ),
    content: (),
    origin: (center, center),
    internal-origin: (left, top),
    border: false,
    margin: 0pt,
    style: none,
    connectors: (),
    bounds: bounds,
    content-bounds: bounds,
    parent: none,
    children: (),
    display-mode: "detailed",
    position: (0pt, 0pt),
    shape: shape,
    get-anchor: get-anchor-fn,
    anchors: anchors-dict,
    is-primitive: true,
    render: (self, mode) => {
      self.shape
    },
  )
}

/// Create a rectangle primitive with anchor points
#let primitive-rect(position, size, fill: none, stroke: 1pt + black, radius: 0pt, label: none, label-size: 7pt) = {
  let (x, y) = position
  let (w, h) = size

  let shape = {
    cetz.draw.rect(
      (x, y),
      (x + w, y + h),
      fill: fill,
      stroke: stroke,
      radius: radius,
    )
    if label != none {
      let label-color = if type(stroke) == color { stroke } else if stroke != none and type(stroke) != bool { stroke.paint } else { black }
      cetz.draw.content((x + w * 0.5, y + h * 0.5), text(size: label-size, fill: label-color, weight: "medium", label))
    }
  }

  let bounds = (x: x, y: y, width: w, height: h)

  let anchors = (
    "top-left": (x, y),
    "top-center": (x + w * 0.5, y),
    "top-right": (x + w, y),
    "center-left": (x, y + h * 0.5),
    "center": (x + w * 0.5, y + h * 0.5),
    "center-right": (x + w, y + h * 0.5),
    "bottom-left": (x, y + h),
    "bottom-center": (x + w * 0.5, y + h),
    "bottom-right": (x + w, y + h),
  )

  let get-anchor = (anchor-name) => {
    let (h-offset, v-offset) = anchor-to-offset(anchor-name)
    (x + w * h-offset, y + h * v-offset)
  }

  create-minimal-component(bounds, shape, anchors, get-anchor)
}

/// Create a circle primitive with anchor points
#let primitive-circle(center, radius, fill: none, stroke: 1pt + black, label: none, label-size: 7pt) = {
  let (cx, cy) = center

  let shape = {
    cetz.draw.circle(center, radius: radius, fill: fill, stroke: stroke)
    if label != none {
      let label-color = if type(stroke) == color { stroke } else if stroke != none and type(stroke) != bool { stroke.paint } else { black }
      cetz.draw.content((cx, cy), text(size: label-size, fill: label-color, weight: "medium", label))
    }
  }

  let bounds = (x: cx - radius, y: cy - radius, width: 2 * radius, height: 2 * radius)

  let anchors = (
    "top": (cx, cy - radius),
    "right": (cx + radius, cy),
    "bottom": (cx, cy + radius),
    "left": (cx - radius, cy),
    "center": (cx, cy),
  )

  let get-anchor = (anchor-name) => {
    let (h-offset, v-offset) = anchor-to-offset(anchor-name)
    let angle = calc.atan2(v-offset - 0.5, h-offset - 0.5)
    (cx + radius * calc.cos(angle), cy + radius * calc.sin(angle))
  }

  create-minimal-component(bounds, shape, anchors, get-anchor)
}

/// Create an ellipse primitive with anchor points
#let primitive-ellipse(center, radius-x, radius-y, fill: none, stroke: 1pt + black, label: none, label-size: 7pt) = {
  let (cx, cy) = center

  let shape = {
    cetz.draw.circle(center, radius: (radius-x, radius-y), fill: fill, stroke: stroke)
    if label != none {
      let label-color = if type(stroke) == color { stroke } else if stroke != none and type(stroke) != bool { stroke.paint } else { black }
      cetz.draw.content((cx, cy), text(size: label-size, fill: label-color, weight: "medium", label))
    }
  }

  let bounds = (x: cx - radius-x, y: cy - radius-y, width: 2 * radius-x, height: 2 * radius-y)

  let anchors = (
    "top": (cx, cy - radius-y),
    "right": (cx + radius-x, cy),
    "bottom": (cx, cy + radius-y),
    "left": (cx - radius-x, cy),
    "center": (cx, cy),
  )

  let get-anchor = (anchor-name) => {
    let (h-offset, v-offset) = anchor-to-offset(anchor-name)
    let angle = calc.atan2(v-offset - 0.5, h-offset - 0.5)
    (cx + radius-x * calc.cos(angle), cy + radius-y * calc.sin(angle))
  }

  create-minimal-component(bounds, shape, anchors, get-anchor)
}

/// Generic primitive wrapper
#let primitive(shape-type, ..args) = {
  if shape-type == "rect" {
    primitive-rect(..args)
  } else if shape-type == "circle" {
    primitive-circle(..args)
  } else if shape-type == "ellipse" {
    primitive-ellipse(..args)
  } else {
    panic("Unknown primitive type: " + str(shape-type))
  }
}
