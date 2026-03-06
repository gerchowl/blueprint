/// Utility functions for hierarchical diagrams
#import "deps.typ": cetz

/// Convert anchor string to numeric values
/// anchor: (left|center|right, top|center|bottom)
#let anchor-to-offset(anchor) = {
  let (h, v) = if type(anchor) == array { anchor } else { (anchor, anchor) }
  let h-offset = if h == "left" or h == left { 0.0 } else if h == "center" { 0.5 } else if h == "right" or h == right { 1.0 } else { 0.5 }
  // Y-up: top = max-Y (1.0), bottom = min-Y (0.0)
  let v-offset = if v == "top" or v == top { 1.0 } else if v == "center" { 0.5 } else if v == "bottom" or v == bottom { 0.0 } else { 0.5 }
  (h-offset, v-offset)
}

/// Normalize gap specification to (x, y) pair
#let normalize-gap(gap) = {
  if type(gap) == length { (gap, gap) }
  else if type(gap) == array and gap.len() == 2 { gap }
  else { (0pt, 0pt) }
}

/// Calculate bounding box from an array of items that have bounds
#let calculate-bounds(items) = {
  let min-x = 0pt
  let min-y = 0pt
  let max-x = 0pt
  let max-y = 0pt
  let has-items = false

  for item in items {
    let item-bounds = if type(item) == dictionary and "bounds" in item {
      item.bounds
    } else {
      none
    }

    if item-bounds != none {
      if not has-items {
        min-x = item-bounds.x
        min-y = item-bounds.y
        max-x = item-bounds.x + item-bounds.width
        max-y = item-bounds.y + item-bounds.height
        has-items = true
      } else {
        min-x = calc.min(min-x, item-bounds.x)
        min-y = calc.min(min-y, item-bounds.y)
        max-x = calc.max(max-x, item-bounds.x + item-bounds.width)
        max-y = calc.max(max-y, item-bounds.y + item-bounds.height)
      }
    }
  }

  if not has-items {
    (x: 0pt, y: 0pt, width: 0pt, height: 0pt)
  } else {
    (x: min-x, y: min-y, width: max-x - min-x, height: max-y - min-y)
  }
}

/// Check if value is none or auto
#let is-none-or-auto(value) = value == none or value == auto

/// Create a 2D vector
#let vec2(x, y) = (x, y)

/// Add two vectors
#let vec-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))

/// Subtract two vectors
#let vec-sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))

/// Scale a vector
#let vec-scale(v, s) = (v.at(0) * s, v.at(1) * s)

/// Vector length
#let vec-len(v) = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))

/// Normalize vector
#let vec-normalize(v) = {
  let len = vec-len(v)
  if len > 0 { vec-scale(v, 1.0 / len) } else { (0, 0) }
}
