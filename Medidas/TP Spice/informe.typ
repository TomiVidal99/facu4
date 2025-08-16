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
  #figure(
    image("Imagenes/1-tensiones.png", width: 100%),
    caption: [Tensiones en el circuito dado],
  )

  La corriente del neutro y parámetros similares se pueden obtener en la simulación, a continuación se ve como efectivamente hay una alta corriente en el neutro.
  #figure(
    image("Imagenes/1-corriente-neutro.png", width: 100%),
    caption: [Corriente del neutro],
  )

  Se identificó que el problema de la corriente en el neutro ($36 A_"RMS"$) que es debido al tercer armónico. Esto se verificó quitando cada armónico individualmente, como se muestra a continuación en las capturas.

  #figure(
    image("Imagenes/1-sin_armonicos.png", width: 100%),
    caption: [Simulación sin el tercer armónico],
  )

  Como se puede ver, sólo cuando se remueven los armónicos se elimina la corriente en el neutro. Una posible solución es simplemente eliminar el nuetro.

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
        [$P_R$], [12012W],
        [$P_S$], [12012W],
        [$P_T$], [12012W],
        [$P_"Total"$], [36038W],
        [$U_R$], [205V],
        [$U_S$], [205V],
        [$U_T$], [205V],
        [$I_R$], [80A],
        [$I_S$], [80A],
        [$I_T$], [80A],
        [S], [49646VA],
        [FP], [0.73],
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
        [*Capacidad [F]*], [*FP*],
        [500p], [0.8379],
        [100u], [0.8576],
        [470u], [0.8969],
        [1000u], [0.708],
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
        [5.06A], [2.75A], [261.35W], [76.64mW],
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
        [*Resistencia [#sym.Omega]*], [*Tensión media [V]*],
        [100], [3.9163],
        [1k], [7.878],
        [10k], [9.1312],
      ),
      caption: [Tensión del capacitor para diferentes valores de R],
      placement: top,
    )
  ]

  = Problema 4
  Se hicieron varios circuitos para poder resolver el problema dado. El uno de los circuitos es con diodos "reales" (tiene alinealidades), otro con diodos "ideales" (sin alinealidades) y otro donde se iteran valores del valor efectivo de la fuente para ver cuando se cumple el error de las alinealidades menor al 5%.

  Con los datos provistos para el problema, se puede calcular la resistencia multiplicadora, pero debido a las imperfecciones de los diodos no se llega al valor deseado, por lo que se iteraron valores de la resistencia hasta llegar al valor deseado, que resultó en $R_m=3907,5#sym.Omega$ aproximadamente. Con esta resistencia $R_m$ en serie a los 50#sym.Omega se puede verificar en la simulación que la corriente máxima se alcanza perfectamente, satisfaciendo las condiciones requeridas.

  #figure(
    image("Imagenes/4-circuito_base.png", width: 100%),
    caption: [Circuito con diodos ideales],
  )
  #figure(
    image("Imagenes/4-circ_diodos_ideales.png", width: 100%),
    caption: [Circuito con diodos ideales],
  )

  #align(center)[
    #figure(
      table(
        columns: (auto, auto, auto),
        align: (center, center, center),
        [], [*Diodos "reales"*], [*Diodos "ideales"*],
        [*Corriente ($m A$)*], [1,001], [1,1309],
      ),
      caption: [Corrientes en la resistencia de $50#sym.Omega$],
      placement: top,
    )
  ]

  Luego se iteraron valores de tensión eficaz en la entrada, considerando que la sinusoide tiene V$sqrt(2)$ (donde V es en Volts eficaces), y se midió la tensión eficaz a la salida, y haciendo el cálculo del error ($e=frac(V_"entrada"-V_"salida", V_"entrada")$), en la siguiene tabla se observan los resultados.

  #figure(
    image("Imagenes/4-circ_iteraciones.png", width: 100%),
    caption: [Circuito empleado para calcular mínimo error de alinealidad],
  )

  #align(center)[
    #figure(
      table(
        columns: (auto, auto, auto),
        align: (center, center, center),
        [*Entrada [$V_text("ef")$]*], [*Salida [$V_text("ef")$]*], [*Error [%]*],
        [23.8546], [22.6796], [4.9952],
        [25.8482], [24.6165], [4.5906],
        [27.8358], [26.6415], [4.2898],
        [29.8243], [28.6234], [4.0268],
        [31.8105], [30.6029], [3.7961],
      ),
      caption: [Error debido a la alinealidad de los diodos variando la tensión de entrada],
      placement: top,
    )
  ]

  Por lo que se concluye que para una entrada mayor a $23.84V_text("ef")$ se tiene un error menor al 5% que era lo que se buscaba.

]
