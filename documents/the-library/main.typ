#import "@preview/obelisk:0.2.0": *
#import "/shared/authors.typ": *

// obelisk tries to set "Inter" which defaults to another variant of the inter font
#show: init.with(fonts: (sans: "Inter Display"))
// obelisk 0.2.0 has leading for level 1 headings that produces clipping
#show heading.where(level: 1): set text(bottom-edge: -9pt)

= The library for the Leliel project

#{
  v-step(-3)
  set align(right)
  set text(14pt, font: "Inter", luma(30%))
  set par(leading: 20pt)
  [Frøya Lydersen]
}

== Define
We are making _frogs_.

=== Declarative
awd
=== Reproducibility

It all begins with a flake. #lorem(13)


=== The end
Woag. #lorem(40)


== The glor
Woage. #lorem(40)


= Frog
Woage. #lorem(40)

== Frog
#lorem(20)
