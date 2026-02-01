#let numEquations = counter("mycounter");
#context numEquations.step()

#let cmd(t) = text[
  #set text(font: "Verdana", fill: rgb("#4171ba"))
  _#raw(t, lang: "bash")_
]

#let lk(href, nombre) = text[
  #text(blue)[#link(href)[_#text(nombre)_]]
]

#let equation(equation) = {
  v(1em)
  block(width: 100%, inset: 0pt, {
    align(center)[
      $#equation$
    ]
    place(right, dx: -1em)[
      (#context numEquations.get().first())
    ]
  })
  context numEquations.step()
  v(1em)
}

#let project(title: "", sub: "", authors: (), date: none, body) = {
  // Set document metadata
  set document(author: authors.join(", "), title: title)
  set text(lang: "es")
  // IEEE page setup for US Letter (8.5in × 11in)
  set page(
    paper: "us-letter",
    margin: (top: 19mm, bottom: 25.4mm, left: 15.875mm, right: 15.875mm),
    columns: 2, // Enable two-column layout
    numbering: "1",
    number-align: center,
  )
  // Set text properties (IEEE uses 10pt for body text)
  set text(font: "Times New Roman", size: 10pt, lang: "es")
  // Configure headings (IEEE style: numbered, bold)
  set heading(numbering: "1.")
  show heading: it => [
    #set text(weight: "bold", size: 11pt)
    #it
    #v(0.5em)
  ]
  // Configure figures for IEEE style (9pt caption, centered images)
  show figure: it => [
    #set text(size: 9pt)
    #v(0.5em)
    #align(center)[
      #it.body
      #v(0.25em)
      #it.caption
    ]
    #v(0.5em)
  ]
  // Title page (single-column for title)
  set page(columns: 1) // Temporarily switch to single-column for title
  align(center)[
    #v(10em)
    #text(16pt, weight: "bold")[#title]
    #v(1em)
    #text(14pt, style: "italic")[#sub]
    #v(1em)
    // Render list of authors
    // #text(12pt)[#authors.join(", ")]
    #text(11pt)[#date]
    #v(1.5em)
    // Uniform image size (e.g., 80% of column width)
    #for author in authors {
      text(11pt, style: "italic")[#author]
      v(.1em)
    }

    #v(4em)
    #image("unlp_logo.png", width: 60%)

  ]
  set footnote.entry(clearance: 8em)
  // set footnote.entry(breakeable: true)
  // Switch back to two-column layout for the body
  set page(columns: 2)
  body
}

#project(
  title: "Problema Especial",
  sub: "Sistemas Embebidos",
  authors: (
    "Tomás Vidal (69854/4)",
  ),
  date: "26 de Enero de 2026",
)[

  = Introducción

  En este trabajo se presentan los resultados del *ensayo directo en carga* realizado sobre un *motor asincrónico trifásico* con rotor jaula de ardilla. El objetivo del ensayo es *caracterizar el comportamiento eléctrico y mecánico del motor* bajo distintos niveles de carga, obteniendo y graficando (en función de la potencia útil $P_u$) los parámetros de funcionamiento: *rendimiento $#math.eta$* , *factor de potencia* $f_p=cos#math.phi$, *corriente de línea* $I_y$ *resbalamiento* _s_, además de la *característica mecánica* n=f(T)(velocidad angular vs. cupla). El método consiste en operar el motor a *tensión y frecuencia nominales*, acoplado a un freno o dinamopéndulo para imponer la carga, y medir *potencia trifásica, tensión, corriente y velocidad* en varios puntos de operación.


]

