/// Layout and positioning system
/// Supports absolute and relative positioning with reference objects
#import "deps.typ": cetz
#import "utils.typ": *
#import "canvas.typ": *

/// Calculate position relative to a reference object
/// ref-obj: dictionary with .bounds and .position
/// anchor: (horizontal, vertical) anchor point on the reference
/// gap: spacing from the anchor point
#let relative(ref-obj, anchor, gap: 1mm) = {
  let (gap-x, gap-y) = normalize-gap(gap)
  let (h-anchor, v-anchor) = anchor-to-offset(anchor)

  let ref-bounds = ref-obj.bounds
  let ref-pos = ref-obj.position

  let ref-anchor-x = ref-pos.at(0) + ref-bounds.width * h-anchor
  let ref-anchor-y = ref-pos.at(1) + ref-bounds.height * v-anchor

  let new-x = ref-anchor-x
  let new-y = ref-anchor-y

  if h-anchor == 0.0 {
    new-x = ref-anchor-x - gap-x
  } else if h-anchor == 1.0 {
    new-x = ref-anchor-x + gap-x
  }

  if v-anchor == 0.0 {
    new-y = ref-anchor-y - gap-y
  } else if v-anchor == 1.0 {
    new-y = ref-anchor-y + gap-y
  }

  (new-x, new-y)
}

/// Calculate position relative to reference with specific anchors on both objects
/// ref-obj: dictionary with .bounds and .position
/// ref-anchor: anchor point on the reference object
/// target-anchor: anchor point on the target object
/// target-bounds: bounds of the target object being placed
/// gap: spacing between the objects
#let relative-with-anchor(ref-obj, ref-anchor, target-anchor, target-bounds: none, gap: 1mm) = {
  let (gap-x, gap-y) = normalize-gap(gap)
  let (ref-h, ref-v) = anchor-to-offset(ref-anchor)
  let (target-h, target-v) = anchor-to-offset(target-anchor)

  let ref-bounds = ref-obj.bounds
  let ref-pos = ref-obj.position

  // Reference anchor point in absolute coordinates
  let ref-anchor-x = ref-pos.at(0) + ref-bounds.width * ref-h
  let ref-anchor-y = ref-pos.at(1) + ref-bounds.height * ref-v

  // Apply gap based on direction
  let new-x = ref-anchor-x
  let new-y = ref-anchor-y

  if ref-h == 0.0 { new-x -= gap-x }
  else if ref-h == 1.0 { new-x += gap-x }

  if ref-v == 0.0 { new-y -= gap-y }
  else if ref-v == 1.0 { new-y += gap-y }

  // Offset by target anchor so the target's anchor aligns with the computed point
  if target-bounds != none {
    new-x -= target-bounds.width * target-h
    new-y -= target-bounds.height * target-v
  }

  (new-x, new-y)
}

/// Calculate bounds for content array
#let calculate-content-bounds(content) = {
  let min-x = 0pt
  let min-y = 0pt
  let max-x = 0pt
  let max-y = 0pt
  let has-content = false

  for item in content {
    let item-bounds = if type(item) == dictionary and "bounds" in item {
      item.bounds
    } else {
      none
    }

    if item-bounds != none {
      if not has-content {
        min-x = item-bounds.x
        min-y = item-bounds.y
        max-x = item-bounds.x + item-bounds.width
        max-y = item-bounds.y + item-bounds.height
        has-content = true
      } else {
        min-x = calc.min(min-x, item-bounds.x)
        min-y = calc.min(min-y, item-bounds.y)
        max-x = calc.max(max-x, item-bounds.x + item-bounds.width)
        max-y = calc.max(max-y, item-bounds.y + item-bounds.height)
      }
    }
  }

  if not has-content {
    (x: 0pt, y: 0pt, width: 1cm, height: 1cm)
  } else {
    (x: min-x, y: min-y, width: max-x - min-x, height: max-y - min-y)
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

/// Position object so its anchor aligns with target-position
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
