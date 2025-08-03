#let project(title: "", author: "", date: none, body) = {
  // Set document metadata
  set document(author: author, title: title)

  // IEEE page setup for US Letter (8.5in × 11in)
  set page(
    paper: "us-letter",
    margin: (top: 19mm, bottom: 25.4mm, left: 15.875mm, right: 15.875mm),
    columns: 2, // Enable two-column layout
    numbering: "1",
    number-align: center,
  )

  // Set text properties (IEEE uses 10pt for body text)
  set text(font: "Times New Roman", size: 10pt, lang: "en")

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
    #v(14em)
    #text(16pt, weight: "bold")[#title]
    #v(1em)
    #text(12pt)[#author]
    #v(1em)
    #text(10pt)[#date]
    #v(6em)
    // Uniform image size (e.g., 80% of column width)
    #image("Imagenes/unlp_logo.png", width: 60%)
  ]

  // Switch back to two-column layout for the body
  set page(columns: 2)
  body
}

// Document content
#project(
  title: "Informe Medidas Eléctricas",
  author: "Tomás Vidal (69854/4)",
  date: "2 de Agosto 2025",
)[
  = Problema 1
  El sistema dado se simuló considerando 4 fuentes para cada fase, una fuente para la señal y otras 3 para los armónicos. Los cables son equivalentes a resistores en serie.

  #figure(
    image("Imagenes/1-sistema.png", width: 100%),
    caption: [Circuito en LTSpice completo],
  )

  La corriente del neutro y parámetros similares se pueden obtener en la simulación, a continuación se ve como efectivamente hay una alta corriente en el neutro.
  #figure(
    image("Imagenes/1-corriente-neutro.png", width: 100%),
    caption: [Corriente del neutro],
  )

  Se identificó que el problema de la corriente en el neutro (1.78A RMS) que es debido al tercer armónico. Esto se verificó quitando cada armónico individualmente, como se muestra a continuación en las capturas.

  #figure(
    image("Imagenes/1-sin_3ro.png", width: 100%),
    caption: [Simulación sin el tercer armónico],
  )
  #figure(
    image("Imagenes/1-sin_5to.png", width: 100%),
    caption: [Simulación sin el quinto armónico],
  )
  #figure(
    image("Imagenes/1-sin_9no.png", width: 100%),
    caption: [Simulación sin el noveno armónico],
  )

  Como se puede ver, sólo cuando se remueve el tercer armónico se elimina la corriente en el neutro. Una posible solución a este problema sería hacer un filtro que lo elimine.

  Para calcular la potencia activa, aparente y factor de potencia, se emplearon las directivas de LTSpice, que permiten efectuar cálculos basados en las simulaciones.

  #figure(
    image("Imagenes/1-directivas.png", width: 100%),
    caption: [Directivas del LTSpice],
  )

  #align(center)[
    #figure(
      table(
        columns: (auto, auto),
        align: (center, center),
        [*Parámetro*], [*Valor*],
        [$P_R$], [11846W],
        [$P_S$], [11811W],
        [$P_T$], [11835W],
        [$P_"Total"$], [6200573W],
        [$U_R$], [206V],
        [$U_S$], [206V],
        [$U_T$], [206V],
        [$I_R$], [84.8A],
        [$I_S$], [84.8A],
        [$I_T$], [84.4A],
        [S], [52367.5255865VA],
        [FP], [0.677760212709],
      ),
      caption: [Parámetros pedidos en el ejercicio],
      placement: top,
    )
  ]

  También se analizó la corriente a través de los capacitores en las cargas, haciendo que se varíe el valor de los mismos en un 30%, esto afecta al valor de potencia; además se puede observar como a por los mismos la corriente está compuesta y podenderada en por los armónicos, cuando se compensa para el valor de 50Hz y la inductancia de 5.5mH

  #figure(
    image("Imagenes/1-corrientes_del_cap.png", width: 100%),
    caption: [Corrientes en el capacitor],
  )

  #align(center)[
    #figure(
      table(
        columns: (auto, auto),
        align: (center, center),
        [*Capacidad (uF)*], [*FP*],
        [1100], [0.677],
        [770], [0.782],
        [1430], [0.72],
        [150], [0.862],
      ),
      caption: [Factor de potencia para varios valores del capacitor],
      placement: top,
    )
  ]

  La mejor compensación que se logró fue con una capacidad de 150uF, esto se consigió a partir de simular iterando valores de la misma capacidad con la directiva *".STEP PARAM Ccompensado _varios valores_"*. Inicialmente se hizo el cálculo para compensar la reactancia inductiva de 5.5mH a 50Hz y esto resultó en 1.84uF, pero el factor de potencia empeoró, por lo que se concluye que el efecto de la inductancia serie de 350uH y los armónicos son significativos y hacen que los cálculos analíticos no sean sencillos.

  = Problema 2
  Se armó en LTSpice el circuito dado en el problema, para el cual se calcularon con las siguientes directivas, el valor de la distorsión armónica total para el caso cuando no se tiene el capacitor, y para el cual en el que sí se tiene, para esto se considera un circuito en el que sólo se tienen las fuentes con los armónicos, y otro en el que se tienen todas las fuentes.

  #figure(
    image("Imagenes/2-circuito.png", width: 100%),
    caption: [Circuito dado],
  )
  #figure(
    image("Imagenes/2-circuitos_solo_armonicos.png", width: 100%),
    caption: [Circuito con sólo los armónicos],
  )
  #figure(
    image("Imagenes/2-directivas.png", width: 100%),
    caption: [Directivas de empleadas],
  )

  Además se corrobora que no se supere la corriente máxima (que efectivamente no lo hace), y eficaz por el capacitor:

  #figure(
    image("Imagenes/2-corriente_capacitor.png", width: 100%),
    caption: [Corrientes en el capacitor],
  )

  También se inspecciona la potencia máxima y media sobre el capacitor:

  #figure(
    image("Imagenes/2-potencia_capacitor.png", width: 100%),
    caption: [Potencia en el capacitor],
  )

  #align(center)[
    #figure(
      table(
        columns: (auto, auto, auto, auto),
        align: (center, center, center, center),
        [*Corriente Máxima*], [*Corriente RMS*], [*Potencia Máxima*], [*Potencia Media*],
        [5.0674A], [2.7962A], [152.697W], [319.82mW],
      ),
      caption: [Corriente y potencia del capacitor],
      placement: top,
    )
  ]

  = Problema 3
  Se armaron los siguientes circuitos para poder hacer las mediciones pertinentes para los diferentes valores de R

  #figure(
    image("Imagenes/3-circuito.png", width: 100%),
    caption: [Circuito en LTSpice],
  )
  #figure(
    image("Imagenes/3-tension_r01k.png", width: 100%),
    caption: [tension media con R=100#sym.Omega],
  )
  #figure(
    image("Imagenes/3-tension_r1k.png", width: 100%),
    caption: [tension media con R=1k#sym.Omega],
  )
  #figure(
    image("Imagenes/3-tension_r10k.png", width: 100%),
    caption: [tension media con R=10k#sym.Omega],
  )

  #align(center)[
    #figure(
      table(
        columns: (auto, auto),
        align: (center, center),
        [*Resistencia (#sym.Omega)*], [*Tensión media (V)*],
        [100], [3.9163],
        [1k], [7.878],
        [10k], [9.1312],
      ),
      caption: [Tensión del capacitor para diferentes valores de R],
      placement: top,
    )
  ]

]
