#let project(title: "", sub: "", author: "", date: none, body) = {
  // Set document metadata
  set document(author: author, title: title)
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
    #text(11pt, style: "italic")[#author]

    // #v(4em)
    // #image("unlp_logo.png", width: 60%)

    // Table of Contents
    #set page(columns: 1) // Single-column for TOC
    #v(2em)
    #text(14pt, weight: "bold")[Tabla de contenido]
    #v(1em)
    #set text(font: "Times New Roman", size: 10pt)
    #outline(
      title: none, // No extra title since we added "Table of Contents" above
      indent: 2em, // Indent entries for hierarchy
      //fill: box(width: 1fr, repeat[.]), // Dotted line for TOC entries
    )
    #v(2em)
    #set page(columns: 2)

  ]
  // Switch back to two-column layout for the body
  set text(lang: "es")
  set page(columns: 2)
  set ref(form: "page")
  body
}

#let reference(t) = text[
  #set text(fill: rgb("#4171ba"))
  _#ref(t)_
]

#let cmd(t) = text[
  #set text(font: "Verdana", fill: rgb("#4171ba"))
  _#raw(t, lang: "bash")_
]

#let lk(href, nombre) = text[
  #text(blue)[#link(href)[_#text(nombre)_]]
]

#let img(src, caption, w: 100%) = text[
  #figure(
    image(src, width: w),
    caption: [#caption],
  )
]

// Document content
#project(
  title: "Bitácora BMS CTA",
  sub: "Esto es simplemente un registro de los eventos/desarrollos/decisiones a lo largo del proyecto.",
  author: "Vidal Tomás",
  date: "18 de Septiembre de 2025",
)[

    = Revisiones
    *26/01/2026*. Descripción del hardware
    
    = Hardware
    // #img("Images/Pasted image 20250814233722.png", "Cable del programador ICE")
    Se conectaron los módulos 


]

//   = Revisiones

//   - *20/11/25*. Código de pruebas del CAN en Arduino. Diseño en bloques de la placa definitiva.
//   - *18/11/25*. Posibles problemas y/o consideraciones del nuevo IC (MAX17853).
//   - *15/11/25*. *CAMBIO DE IC*. Se encontraron otros IC que resuelven el problema, en particular el MAX17853.
//   - *14/11/25*. Se investigó como hacer la medición de las temperaturas de una forma más eficiente.
//   - *13/11/25*. Se descartó la medicón de las celdas individuales (puesto que están en paralelo).
//   - *11/11/25*. *CAMBIO DE TOPOLOGÍA*. Se reemplazó la medición de las tensiones con operacionales por un IC, el *MAX11068*.

//   = Recomendaciones para el lector

//   Los cambios principales de cada inciso se listan al inicio de cada uno, con fecha del suceso. La idea es que esto es más relevante que el contenido de la sección, tal que lo que el cambio dice sobreescribe al resto, por lo que hay secciones que quedan descartadas por los cambios/actualizaciones; por lo que se recomienda prestar atención a estos cambios primero. Las secciones se dejan a modo de registro, por eso puede que no esté vigente, pero sí descripta.


//   = Pines para flashear (con el programmer ICE)
//   De la documentación #lk("Datasheets/Atmel-ICE_UserGuide.pdf", "Atmel-ICE_UserGuide.pdf") en las páginas 15 y 40 se explica como conectar para flashear.

//   #img("Images/Pasted image 20250814233722.png", "Cable del programador ICE")

//   #img("Images/Pasted image 20250814234021.png", "Socket de la placa para el cable ICE")

//   En mi caso usé los pines P9 para programar uno de los micros.

//   #img("Images/Pasted image 20250815001249.png", "Pinout del socket en la placa")

//   = Consejos para programar
//   Atmel tiene muchas notas de aplicación que enseñan más o menos paso a paso de cómo programar la serie Xmega, se puede comenzar con la nota #lk("Datasheets/AVR1000.pdf", "AVR1000"), que explica cómo comenzar a programar, y luego hay notas para usos específicos, como por ejemplo de cómo usar UART, o cómo programar los ADCs, etc.
//   Las definiciones de las direcciones de los puertos están en _avr/io.h_ que automáticamente importa/define _iox32e5.h_, donde se encuentran las definiciones. A diferencia de otros AVRs los puertos son structs que permiten modificar las salidas de los puertos. Ej:

//   - *Actualización 15/9/2025:*
//   ```c
//   /*
//    * main.c
//    * Autor: Tomás Vidal
//    */

//   #define F_CPU 16000000UL
//   #define __AVR_ATxmega32E5__

//   #include <xc.h>
//   #include <util/delay.h>
//   #include "definitions.h"
//   #include "setup_clock.h"

//   int main(void)
//   {

//     setup_clock();
//     PORTD.DIRSET = PIN3_bm;

//     while (1)
//     {

//       PORTD.OUTTGL = PIN3_bm;
//       _delay_ms(100);
//     }
//   }
//   ```

//   _El reloj que se emplea es el interno de 2MHz, por lo que habría que configurar una fuente externa para el reloj, a través de los registros de configuración_

//   == Entorno de desarrollo para programar
//   Para programar este micro (ATXmega32E5) hay que instalarse Microchip Studio, y dependiendo de si se desea o no tener un mejor flujo de trabajo se puede emplear VSCode u otro editor con _make_, para compilar y flashear usando _Makefile_; pero aunque se desee usar _make_ se debe instalar Microchip Studio de todas maneras, ya que con este se instalan todas las dependencias necesarias para el compilado que el _Makefile_ emplea.

//   = Compilación
//   - *Actualización el 15/09/2025* \
//     Leí el compilado que hace Microchip por atrás con Makefile, y lo use para hacer mi propio Makefile local. Para compilar hay que correr #cmd("make") dentro de la carpeta _"Codigo"_, y luego para flashear (programar el micro) hay que correr el comando #cmd("make flash") y ya está. Así no hay que instalarse Microchip Studio ni nada.

//   Para compilar se empleó Microchip Studio, allí se creó un proyecto con el ATXMega32E5 y se emplearon las librerias oficiales de ATmel. Para flashear también se hizo uso de Microchip Studio y se empleó la interfaz (hay que ir a Tools->Device Programming->Read (device signature) y en la pestaña Production File se puede hacer el flashing dado un ELF, este ELF es el que se compila con avrgcc)

//   = Protocolo CAN

//   Las especificaciones del protocolo CAN empleadas son las del estándar #lk("Datasheets/ISO-11898-1-2024.pdf", "ISO 11898-1"), además como complemento se hizo uso de la nota de aplicación: #lk("Datasheets/gettingStartedWithCANBus.pdf", "gettingStartedWithCANBus.pdf")


//   = Mejora de precisión del ADC (sobremuestreo)

//   En la serie ATX se tiene ADC de 12 bits, y haciendo sobremuestreo se puede obtener precisión de 16 bits. Se tiene que cumplir Nyquist con $f_"sobremuestreo" = 4^n f_"Nyquist"$, con *$f_"Nyquist"$* siendo la máxima frecuencia que se desea observar, *n* la cantidad de bits que se emplearán ($12 < n #math.lt.eq 16$) y *$f_"muestreo"$* la frecuencia requerida para logar estas relaciones.

//   Atmel provee un #lk("https://github.com/eewiki/asf/blob/master/xmega/applications/xmega_adc_oversampling_demo", "ejemplo") de código.
//   Atmel provee muchas notas de aplicación en su website, aunque es más fácil buscarlas #lk("https://circuitdigest.com/microcontroller-projects/arduino-can-tutorial-interfacing-mcp2515-can-bus-module-with-arduino", "en internet") simplemente poniendo "Microchip application note ...", y los códigos de ejemplos se pueden encontrar en internet también o en su #lk("https://start.atmel.com/#examples", "website").

//   Si se usa una referencia de *1.5V*, entonces se puede lograr una precisión de miliVolts con *13bits*. $(1.5V) / 2^13 = 0.18"mV"$

//   = Implementación del protocolo CAN en la placa de prueba

//   Para hacer la lectura se configuró el ADC en modo diferencial sin signo con 12bits y ganancia 1. Se emplearon los siguientes pines:

//   - *Actualización el 18/09/2025* \
//     Se cambiaron los pines del ADC para que se pueda conectar el UART.

//   #let ADC_H_CODE = read("Codigo/include/ADC.h")
//   #raw(ADC_H_CODE, lang: "c")

//   == Código de prueba del CAN

//   Para empezar a hacer pruebas con el protocolo se empleó un código de ejemplo de transmisor y receptor encontrado en internet. El mismo se hace a partir de la #lk("https://github.com/autowp/arduino-mcp2515", "librería para MCP2515"), y se implementa en Arduino. Esto me permite verificar lo que luego haga en C para el ATXMega32E5.

//   = UART

//   Se configuró USARTD0 para tener una conexión serial y poder leer los datos medidos con el micro.
//   Los pines son los siguientes:
//   - PD3 (25) (TXD0) (LED_1)
//   - PD2 (26) (RXD0) (LED_2)

//   #let UART_H_CODE = read("Codigo/include/UART.h")
//   #raw(UART_H_CODE, lang: "c")

//   == Bibliografía
//   - #lk(
//       "https://morf.lv/guide-to-xmega-usart-aka-serial-communication",
//       "https://morf.lv/guide-to-xmega-usart-aka-serial-communication",
//     )

//   = Circuito

//   #img("PLACA_DIAGRAMA_BLOQUES.png", "Diagrama en bloques del circuito")

//   == Medición de tensión

//   - *Actualización el 13/11/2025*: se descartó el uso de este operacional para la medición de tensión. \

//   Para hacer la etapa de medición se empleó el integrado #lk("Datasheets/ad8479.pdf", "AD8479"), debido a las especificaciones de tensión de modo común. Para lo cual el diseño se basó en el circuito dado por el fabricante.

//   #img("Images/medicion_V.png", "Esquemático de la hoja de datos")

//   == Nueva topología con MAX11068

//   Previamente se había planteado un diseño con operacionales y toda electrónica discreta, para hacer las mediciones. Todo esto fue reemplazado por el integrado #lk("Datasheets/MAX11068.pdf", "MAX11068"), el mismo es capaz de realizar mediciones de hasta *12 celdas* y *ecualizaciones de las celdas (200mA)*.
//   Esto nos permite deshacernos de las fuentes partidas para hacer las mediciones con alto rechazo a modo común, que era el mayor problema del diseño anterior.

//   === Problemas del MAX11068
//   1. _El I2C no es estandar. Por lo que usarlo en conjunto con otros dispositivos conectados en Daisy-Chain es más complejo._

//   === Aislación ATXMega32E5/MAX11068

//   Para evitar _traer_ el modo común a la parte del microcontrolador, se emplea un aislador entre los chips.

//   = Sistema actual con MAX11068

//   Se pensó en usar el #lk("https://www.analog.com/en/products/max11068.html#documentation", "MAX11068"), ya que resuelve el problema de la fuente partida para el alto rechazo al modo común, y además potencialmente la lectura de las temperaturas.
//   En el link #lk("https://www.analog.com/en/products/max11068.html#documentation", "https://www.analog.com/en/products/max11068.html#documentation") se tiene la _documentación, notas de aplicación y demás_.

//   #img("Images/bloques_13_11_25.jpeg", "Diagrama en bloques del sistema")

//   = Adquisión de temperaturas a través de MUX

//   Una posible idea es medir las temperaturas con un #lk("https://www.analog.com/en/products/max382.html", "MUX") y el MAX11068, así no tengo que emplear el OP294 10 veces, y simplemente usar lo que ya pueden hacer los ICs, como dice la #lk("https://www.analog.com/en/resources/design-notes/measure-multiple-temperatures-in-batterymanagement-systems-and-save-power-too.html", "nota de aplicación de Analog Devices").

//   #img("Images/AN_AD_MUX_temp.png", "Nota de aplicación de Analog Devices")<AP_AD_TEMP>

//   En #reference(<AP_AD_TEMP>) se muestra como se conectan termistores para leer múltiples temperaturas, con un sólo MAX11068. Así no se requieren más operacionales ni componentes extras.

//   = Cambio de IC a MAX17853

//   Buscando integrados de la familia del MAX11068 y de las notas de aplicación de Analog Devices, se encontró que existen versiones más nuevas del MAX11068, de hecho hay una familia entera de IC de Analog Devices para estas aplicaciones en particular, los #lk("https://www.analog.com/media/en/technical-documentation/data-sheets/adbms6815.pdf", "ADBMS"). Pero por cuestiones de disponibilidad (no se pueden conseguir ni en Digikey o Mouser), se decidió optar por el #lk("Datasheets/max17853.pdf", "MAX17853"), que se una versión más nueva de la familia del  MAX11068.

//   == Características y cambios más importantes con el nuevo IC

//   Es importante mencionar por qué se usa MAX17853, y no es simplemente porque sea más nuevo, a diferencia del MAX11068, el MAX17853 tiene *6 lecturas de temperaturas*, por lo que no se necesitan multiplexores para poder leer las temperaturas; además el MAX17853 permite *Daisy-Chain el par diferencial*, con *acoplamiento capacitivo* (no galvánico), y está preparado para poder leer un stack de hasta *32 módulos*, lo que hace que se puedan leer hasta $14*32=448$ celdas. \
//   Para nuestra aplicación, sólo nos importa conectar MAX17853 entre sí y que midan 5 baterías y 5 temperaturas, ya que al tener 95 baterías se requiere un número para de placas ($95/5=19$ placas); por lo que potencialmente se podrían conectar un total de $5*32=160$ baterías con estas placas. También este diseño reduce la complejidad extremadamente, ya que sólo se requieren un MAX17853 y los transistores/resistencias de balanceo por SLAVE, y sólo el MASTER requiere un ATXMega32E5 y el sensado de corriente.

//   == Nueva topología/diagrama en bloques

//   #img("Images/bloques_15_11_25.jpeg", "Diagrama en bloques con el MAX17853")

//   #img("Images/diag_bloques_MAX17853.png", "Diagrama en bloques con el MAX17853 (provisto por el fabricante)")

//   #img("Images/diag_bloques_MAX117853_fabricante.png", "Diagrama en bloques de posible sistema completo con Daisy-Chain (provisto por el fabricante)")

//   ==== Mínima cantidad de celdas

//   _"The minimum number of cells connected to any one device is limited by the device’s minimum operating voltage. The 9V (min) for VDCIN usually requires at least two Li-ion, six NiMH or six SuperCap cells per module."_ (página 295)

//   = Diseño completo con MAX17853

//   #img("Images/BLOQUES_PLACA.jpeg", "Diagrama en bloques de la placa hasta el momento")

//   Se hace una única placa, considerando que sólo se poblaría la parte del MASTER para el MASTER, y luego para los SLAVES (bloque en naranja en la foto) se incluye sólo el bloque del MAX17853 y los BJTs de balanceo.

//   == Consideraciones

//   1. Se alimenta de 9V a 65V, con lo que se requieren un mínimo de *3 celdas* a medir, $"9V"/"3.6V" < 3$ (nosotros medimos 5). _Tabla 64, página 147_. _Igual como se menciona antes, la documentación dice que se requieren un mínimo de 2_.

//   == Esquema de comunicación

//   #img("Images/BLOQUES_COMUNICACION_UART.png", "Diagrama en bloques de la conexión UART entre los módulos")

//   Se puede emplear aislación con transformadores también como dice la documentación: _"Two UART ports are utilized, a lower port (RXL/TXL) and an upper port (RXU/TXU). Each port consists of a differ- ential line driver and differential line receiver. DC-blocking *capacitors or transformers* can be used to isolate daisy- chained devices operating at different common-mode voltages. During communication, the character encoding provides a balanced signal (50% duty cycle) that ensures charge neutrality on the isolation capacitors."_.

//   = NOTAS

//   1. ¿Debería considerar UART doble? (dos pares diferenciales, uno para Rx y otro para Tx).
//   2. ¿Hay limitaciones del SNR y EMC del par diferencial? (esto tiene que ver con la pregunta 1)
//   3. ¿Cuál es la máxima distancia del par diferencial UART entre módulos?
//   4. ¿Es la referencia interna estable? hay mucho drift? Referencia de tensión externa? (*Tiene referencia externa ($V_"ref"$)*). _Si se toma la referencia externa para todos los SLAVES, se requiere el circuito para cada placa_.
//   5. ¿Cómo se puede desvincular la alimentación del modo común? (ver imagen)
//   #img("Images/Acomple_ModoComun_Fuente.jpeg", "Alimentación del master con modo común")