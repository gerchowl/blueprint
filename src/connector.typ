/// Connector system for component interfaces
#import "deps.typ": cetz
#import "utils.typ": *
#import "style.typ": *

/// Create a connector (pure function, returns a dict)
#let connector(name, position, group: none, count: 1, group-display: "auto", group-label: none, style: none) = {
  let conn-style = if style != none { style } else { default-connector-style }
  (
    name: name,
    position: position,
    group: group,
    count: count,
    group-display: group-display,
    group-label: group-label,
    style: conn-style,
    index: none,
  )
}

/// Render individual connector (returns CeTZ drawing commands)
#let render-connector-individual(conn) = {
  let (x, y) = if type(conn.position) == array { conn.position } else { (conn.position.x, conn.position.y) }
  let s = conn.style
  let size = s.at("size", default: 4pt)
  let shape = s.at("shape", default: "circle")
  let fill = s.at("fill", default: white)
  let stroke = s.at("stroke", default: 1pt + black)

  if shape == "circle" {
    cetz.draw.circle((x, y), radius: size, fill: fill, stroke: stroke)
  } else {
    cetz.draw.rect(
      (x - size, y - size),
      (x + size, y + size),
      fill: fill,
      stroke: stroke,
    )
  }
}

/// Render connector group collapsed
#let render-connector-group-collapsed(conn) = {
  let (x, y) = if type(conn.position) == array { conn.position } else { (conn.position.x, conn.position.y) }
  let label = if conn.group-label != none {
    conn.group-label
  } else {
    "[1.." + str(conn.count) + "]"
  }

  cetz.draw.line((x - 5pt, y), (x - 2pt, y), stroke: 1pt + black)
  cetz.draw.line((x + 2pt, y), (x + 5pt, y), stroke: 1pt + black)
  cetz.draw.line((x - 2pt, y - 2pt), (x - 2pt, y + 2pt), stroke: 1pt + black)
  cetz.draw.line((x + 2pt, y - 2pt), (x + 2pt, y + 2pt), stroke: 1pt + black)
  cetz.draw.content((x, y - 8pt), [*#label*])
}

/// Render connector group expanded
#let render-connector-group-expanded(conn) = {
  let (x, y) = if type(conn.position) == array { conn.position } else { (conn.position.x, conn.position.y) }
  let spacing = 8pt
  let start-x = x - (conn.count - 1) * spacing / 2

  for i in range(conn.count) {
    let conn-x = start-x + i * spacing
    render-connector-individual((
      name: conn.name,
      position: (conn-x, y),
      style: conn.style,
      index: i,
    ))
  }
}

/// Render connector based on display mode
#let render-connector(connector, display-mode) = {
  if connector.group != none {
    if display-mode == "high-level" or (display-mode == "auto" and connector.count > 5) {
      render-connector-group-collapsed(connector)
    } else if display-mode == "expanded" or connector.group-display == "expanded" {
      render-connector-group-expanded(connector)
    } else {
      render-connector-group-collapsed(connector)
    }
  } else {
    render-connector-individual(connector)
  }
}

/// Get connector by name from a component dict
#let get-connector(comp, connector-name, index: none) = {
  for conn in comp.connectors {
    if conn.name == connector-name {
      if index != none and conn.group != none {
        return conn + (position: calculate-connector-position(conn, index), index: index)
      } else {
        return conn
      }
    }
  }
  panic("Connector " + str(connector-name) + " not found in component " + str(comp.name))
}

/// Calculate position of a specific connector in a group
#let calculate-connector-position(conn, index) = {
  let (x, y) = if type(conn.position) == array { conn.position } else { (conn.position.x, conn.position.y) }
  let spacing = 8pt
  let start-x = x - (conn.count - 1) * spacing / 2
  let conn-x = start-x + index * spacing
  (conn-x, y)
}

/// Calculate bounds for all connectors
#let calculate-connector-bounds(connectors, content-bounds) = {
  let min-x = content-bounds.x
  let min-y = content-bounds.y
  let max-x = content-bounds.x + content-bounds.width
  let max-y = content-bounds.y + content-bounds.height
  let has-connectors = false

  for conn in connectors {
    has-connectors = true
    let (x, y) = if type(conn.position) == array { conn.position } else { (conn.position.x, conn.position.y) }
    let size = if conn.style != none { conn.style.at("size", default: 4pt) } else { 4pt }
    min-x = calc.min(min-x, x - size)
    min-y = calc.min(min-y, y - size)
    max-x = calc.max(max-x, x + size)
    max-y = calc.max(max-y, y + size)
  }

  if not has-connectors {
    content-bounds
  } else {
    (x: min-x, y: min-y, width: max-x - min-x, height: max-y - min-y)
  }
}
