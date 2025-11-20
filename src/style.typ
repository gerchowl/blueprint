/// Style system for hierarchical diagrams
/// Supports reusable styles, themes, and inheritance

/// Default style registry
#let style-registry = state("style-registry", (:))

/// Define a style
#let style(name, component-style: (:), connector-style: (:), edge-style: (:), extends: none) = {
  let base-style = if extends != none {
    style-registry.get().at(extends, default: (:))
  } else {
    (:)
  }

  let new-style = (
    component: base-style.at("component", default: (:)) + component-style,
    connector: base-style.at("connector", default: (:)) + connector-style,
    edge: base-style.at("edge", default: (:)) + edge-style,
  )

  style-registry.update(d => {
    d.insert(name, new-style)
    d
  })

  new-style
}

/// Get a style by name
#let get-style(name) = style-registry.get().at(name, default: (:))

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

/// Apply style to component
#let apply-component-style(component, style-name: none) = {
  let style = if style-name != none {
    get-style(style-name).at("component", default: default-component-style)
  } else {
    default-component-style
  }

  component + (style: style)
}

/// Apply style to connector
#let apply-connector-style(connector, style-name: none) = {
  let style = if style-name != none {
    get-style(style-name).at("connector", default: default-connector-style)
  } else {
    default-connector-style
  }

  connector + (style: style)
}

/// Apply style to edge
#let apply-edge-style(edge, style-name: none) = {
  let style = if style-name != none {
    get-style(style-name).at("edge", default: default-edge-style)
  } else {
    default-edge-style
  }

  edge + (style: style)
}

/// Define a theme (collection of styles)
#let theme(name, styles: (:)) = {
  for (style-name, style-def) in styles.pairs() {
    style(style-name, ..style-def)
  }
}

