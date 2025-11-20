/// Standard drawing primitives with anchor points
#import "@preview/cetz:0.3.2": *
#import "utils.typ": *

/// Create a rectangle primitive with anchor points
#let primitive-rect(position, size, fill: none, stroke: 1pt + black, radius: 0pt) = {
  let (x, y) = position
  let (w, h) = size
  
  let shape = cetz.draw.rect(
    (x, y),
    (x + w, y + h),
    fill: fill,
    stroke: stroke,
    radius: radius,
  )
  
  let bounds = (x: x, y: y, width: w, height: h)
  
  (
    shape: shape,
    bounds: bounds,
    get-anchor: (anchor-name) => {
      let (h-offset, v-offset) = anchor-to-offset(anchor-name)
      (x + w * h-offset, y + h * v-offset)
    },
    anchors: (
      "top-left": (x, y),
      "top-center": (x + w * 0.5, y),
      "top-right": (x + w, y),
      "center-left": (x, y + h * 0.5),
      "center": (x + w * 0.5, y + h * 0.5),
      "center-right": (x + w, y + h * 0.5),
      "bottom-left": (x, y + h),
      "bottom-center": (x + w * 0.5, y + h),
      "bottom-right": (x + w, y + h),
    ),
  )
}

/// Create a circle primitive with anchor points
#let primitive-circle(center, radius, fill: none, stroke: 1pt + black) = {
  let (cx, cy) = center
  
  let shape = cetz.draw.circle(center, radius: radius, fill: fill, stroke: stroke)
  
  let bounds = (x: cx - radius, y: cy - radius, width: 2 * radius, height: 2 * radius)
  
  (
    shape: shape,
    bounds: bounds,
    get-anchor: (anchor-name) => {
      let (h-offset, v-offset) = anchor-to-offset(anchor-name)
      let angle = calc.atan2(v-offset - 0.5, h-offset - 0.5)
      (cx + radius * calc.cos(angle), cy + radius * calc.sin(angle))
    },
    anchors: (
      "top": (cx, cy - radius),
      "right": (cx + radius, cy),
      "bottom": (cx, cy + radius),
      "left": (cx - radius, cy),
      "center": (cx, cy),
    ),
  )
}

/// Create an ellipse primitive with anchor points
#let primitive-ellipse(center, radius-x, radius-y, fill: none, stroke: 1pt + black) = {
  let (cx, cy) = center
  
  let shape = cetz.draw.ellipse(center, radius-x: radius-x, radius-y: radius-y, fill: fill, stroke: stroke)
  
  let bounds = (x: cx - radius-x, y: cy - radius-y, width: 2 * radius-x, height: 2 * radius-y)
  
  (
    shape: shape,
    bounds: bounds,
    get-anchor: (anchor-name) => {
      let (h-offset, v-offset) = anchor-to-offset(anchor-name)
      let angle = calc.atan2(v-offset - 0.5, h-offset - 0.5)
      (cx + radius-x * calc.cos(angle), cy + radius-y * calc.sin(angle))
    },
    anchors: (
      "top": (cx, cy - radius-y),
      "right": (cx + radius-x, cy),
      "bottom": (cx, cy + radius-y),
      "left": (cx - radius-x, cy),
      "center": (cx, cy),
    ),
  )
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
    error("Unknown primitive type: " + str(shape-type))
  }
}

