/// Layout and positioning system
/// Supports absolute and relative positioning with reference objects
#import "deps.typ": cetz
#import "utils.typ": *
#import "canvas.typ": *

/// Object registry for relative positioning
#let object-registry = state("object-registry", (:))

/// Register an object for relative positioning
#let register-object(name, bounds, position) = {
  object-registry.update(d => {
    d.insert(name, (bounds: bounds, position: position))
    d
  })
}

/// Get object by name
#let get-object(name) = object-registry.get().at(name, default: none)

/// Calculate position relative to a reference object
#let relative(ref-object-name, anchor, gap: 1mm) = {
  let ref-obj = get-object(ref-object-name)
  if ref-obj == none {
    error("Reference object not found: " + str(ref-object-name))
  }

  let (gap-x, gap-y) = normalize-gap(gap)
  let (h-anchor, v-anchor) = anchor-to-offset(anchor)

  let ref-bounds = ref-obj.bounds
  let ref-pos = ref-obj.position

  // Calculate position based on anchor point of reference
  let ref-anchor-x = ref-pos.at(0) + ref-bounds.width * h-anchor
  let ref-anchor-y = ref-pos.at(1) + ref-bounds.height * v-anchor

  // Determine placement direction based on anchor
  let new-x = ref-anchor-x
  let new-y = ref-anchor-y

  if h-anchor == 0.0 { // left
    new-x = ref-anchor-x - gap-x
  } else if h-anchor == 1.0 { // right
    new-x = ref-anchor-x + gap-x
  }

  if v-anchor == 0.0 { // top
    new-y = ref-anchor-y - gap-y
  } else if v-anchor == 1.0 { // bottom
    new-y = ref-anchor-y + gap-y
  }

  (new-x, new-y)
}

/// Calculate position relative to a reference object with specific anchor
#let relative-with-anchor(ref-object-name, ref-anchor, target-anchor, gap: 1mm) = {
  let ref-obj = get-object(ref-object-name)
  if ref-obj == none {
    error("Reference object not found: " + str(ref-object-name))
  }

  let (gap-x, gap-y) = normalize-gap(gap)
  let (ref-h, ref-v) = anchor-to-offset(ref-anchor)
  let (target-h, target-v) = anchor-to-offset(target-anchor)

  let ref-bounds = ref-obj.bounds
  let ref-pos = ref-obj.position

  // Calculate reference anchor point
  let ref-anchor-x = ref-pos.at(0) + ref-bounds.width * ref-h
  let ref-anchor-y = ref-pos.at(1) + ref-bounds.height * ref-v

  // Calculate target position (we'll need object bounds to calculate this properly)
  // For now, return the reference anchor point adjusted by gap
  let new-x = ref-anchor-x
  let new-y = ref-anchor-y

  if ref-h == 0.0 { // left side
    new-x = ref-anchor-x - gap-x
  } else if ref-h == 1.0 { // right side
    new-x = ref-anchor-x + gap-x
  }

  if ref-v == 0.0 { // top
    new-y = ref-anchor-y - gap-y
  } else if ref-v == 1.0 { // bottom
    new-y = ref-anchor-y + gap-y
  }

  (new-x, new-y)
}

/// Calculate bounds for content
#let calculate-content-bounds(content) = {
  // Calculate actual bounds from content
  // Content can be primitives, other components, or cetz drawable objects
  let min-x = 0pt
  let min-y = 0pt
  let max-x = 0pt
  let max-y = 0pt
  let has-content = false

  for item in content {
    let item-bounds = if type(item) == "dictionary" {
      if "bounds" in item {
        item.bounds
      } else if "shape" in item {
        // Primitive with shape
        item.bounds
      } else {
        none
      }
    } else {
      none
    }

    if item-bounds != none {
      has-content = true
      min-x = calc.min(min-x, item-bounds.x)
      min-y = calc.min(min-y, item-bounds.y)
      max-x = calc.max(max-x, item-bounds.x + item-bounds.width)
      max-y = calc.max(max-y, item-bounds.y + item-bounds.height)
    }
  }

  // Return default if no content with bounds found
  if not has-content {
    (
      x: 0pt,
      y: 0pt,
      width: 1cm,
      height: 1cm,
    )
  } else {
    (
      x: min-x,
      y: min-y,
      width: max-x - min-x,
      height: max-y - min-y,
    )
  }
}

/// Calculate component border bounds including margin
#let calculate-border-bounds(content-bounds, margin) = {
  let (margin-x, margin-y) = normalize-gap(margin)
  (
    x: content-bounds.x - margin-x,
    y: content-bounds.y - margin-y,
    width: content-bounds.width + 2 * margin-x,
    height: content-bounds.height + 2 * margin-y,
  )
}

/// Calculate anchor position from bounds
#let anchor-position(bounds, anchor) = {
  let (h-offset, v-offset) = anchor-to-offset(anchor)
  (
    bounds.x + bounds.width * h-offset,
    bounds.y + bounds.height * v-offset,
  )
}

/// Position object at anchor point
#let position-at-anchor(bounds, anchor, target-position) = {
  let (h-offset, v-offset) = anchor-to-offset(anchor)
  let anchor-pos = anchor-position(bounds, anchor)
  let (tx, ty) = target-position
  let (ax, ay) = anchor-pos

  (
    tx - ax + bounds.x,
    ty - ay + bounds.y,
  )
}

