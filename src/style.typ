/// Style system for hierarchical diagrams
/// Supports reusable styles, themes, and inheritance

/// Default component style
#let default-component-style = (
  fill: none,
  stroke: 1pt + black,
  border-style: "solid",
  border-radius: 0pt,
  margin: 2mm,
)

/// Default connector style
#let default-connector-style = (
  size: 4pt,
  shape: "circle",
  fill: white,
  stroke: 1pt + black,
)

/// Default edge style
#let default-edge-style = (
  stroke: 1pt + black,
  marks: "->",
  dash: none,
  decorations: none,
)

/// Define a style (pure function, returns a style dict)
#let style(name, component-style: (:), connector-style: (:), edge-style: (:), base: none) = {
  let base-style = if base != none and type(base) == dictionary {
    base
  } else {
    (component: (:), connector: (:), edge: (:))
  }

  (
    name: name,
    component: base-style.at("component", default: (:)) + component-style,
    connector: base-style.at("connector", default: (:)) + connector-style,
    edge: base-style.at("edge", default: (:)) + edge-style,
  )
}

/// Apply style to component dict
#let apply-component-style(component, style-def) = {
  let s = if style-def != none {
    style-def.at("component", default: default-component-style)
  } else {
    default-component-style
  }
  component + (style: s)
}

/// Apply style to connector dict
#let apply-connector-style(connector, style-def) = {
  let s = if style-def != none {
    style-def.at("connector", default: default-connector-style)
  } else {
    default-connector-style
  }
  connector + (style: s)
}

/// Apply style to edge dict
#let apply-edge-style(edge, style-def) = {
  let s = if style-def != none {
    style-def.at("edge", default: default-edge-style)
  } else {
    default-edge-style
  }
  edge + (style: s)
}

/// Define a theme (collection of named styles)
/// Returns a dictionary of style-name -> style-dict
#let theme(name, styles: (:)) = {
  let result = (name: name)
  for (style-name, style-def) in styles.pairs() {
    result.insert(style-name, style(style-name, ..style-def))
  }
  result
}
