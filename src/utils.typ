/// Utility functions for hierarchical diagrams
#import "deps.typ": cetz

/// Convert anchor string to numeric values
/// anchor: (left|center|right, top|center|bottom)
#let anchor-to-offset(anchor) = {
  let (h, v) = if type(anchor) == array { anchor } else { (anchor, anchor) }
  let h-offset = if h == "left" { 0.0 } else if h == "center" { 0.5 } else if h == "right" { 1.0 } else { 0.5 }
  let v-offset = if v == "top" { 0.0 } else if v == "center" { 0.5 } else if v == "bottom" { 1.0 } else { 0.5 }
  (h-offset, v-offset)
}

/// Normalize gap specification to (x, y) pair
#let normalize-gap(gap) = {
  if type(gap) == length { (gap, gap) }
  else if type(gap) == array and gap.len() == 2 { gap }
  else { (0pt, 0pt) }
}

/// Calculate bounding box from content
#let calculate-bounds(content) = {
  // Placeholder - will be implemented with cetz bounds calculation
  (x: 0pt, y: 0pt, width: 0pt, height: 0pt)
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

