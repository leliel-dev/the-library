#import "@preview/obelisk:0.2.0": *

#show: init.with(fonts: (sans: "Inter Display")) // obelisk tries to set "Inter" which defaults to another variant of the inter font,, nya thinks we want this one.
#show link: underline
#show link: set text(fill: blue)

#show heading.where(level: 1): set text(bottom-edge: -9pt)

= The library for the Leliel project

#place(right + top, dx: -50pt, dy: 84pt, float: false)[
  #set text(14pt, font: "Inter", luma(30%))
  #set par(leading: 20pt)
  author1\
  author2
]

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
