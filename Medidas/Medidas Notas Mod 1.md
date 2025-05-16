
# 1. Métodos de medidas

## Índice

- [1. Métodos de medidas](#1.%20Métodos%20de%20medidas)
	- [Índice](##Índice)
	- [1.1. Clasificaciones](##1.1.%20Clasificaciones)
	- [1.2. Método de oposición](##1.2.%20Método%20de%20oposición)
		- [1.2.1. Explicación](###1.2.1.%20Explicación)
	- [1.3. Método del voltímetro diferencial](##1.3.%20Método%20del%20voltímetro%20diferencial)
		- [1.3.1. Pero si se hace un pequeño ajuste, se mejora mucho](###1.3.1.%20Pero%20si%20se%20hace%20un%20pequeño%20ajuste,%20se%20mejora%20mucho)
	- [1.4. Método del voltímetro amperímetro](##1.4.%20Método%20del%20voltímetro%20amperímetro)
		- [1.4.1. Conexión corta](###1.4.1.%20Conexión%20corta)
		- [1.4.2. Conexión larga](###1.4.2.%20Conexión%20larga)
		- [1.4.3. IMPORTANTE: criterio para elegir entre la conexión corta o la conexión larga](###1.4.3.%20IMPORTANTE:%20criterio%20para%20elegir%20entre%20la%20conexión%20corta%20o%20la%20conexión%20larga)
- [2. Resistores de muy alto valor](#2.%20Resistores%20de%20muy%20alto%20valor)
- [3. Resistores de muy bajo valor](#3.%20Resistores%20de%20muy%20bajo%20valor)
- [4. Método de Wheatstone](#4.%20Método%20de%20Wheatstone)
- [5. Digital vs Analógico](#5.%20Digital%20vs%20Analógico)
	- [5.2 Conversor de doble rampa](##5.2%20Conversor%20de%20doble%20rampa)
- [6. Parámetros importantes de las señales en mediciones digitales](#6.%20Parámetros%20importantes%20de%20las%20señales%20en%20mediciones%20digitales)
		- [6.1 Voltímetros de valor medio](###6.1%20Voltímetros%20de%20valor%20medio)
		- [6.1.1 Error de Factor de Forma de Onda](###6.1.1%20Error%20de%20Factor%20de%20Forma%20de%20Onda)
		- [6.2 Voltímetros de valor eficaz (True RMS)](###6.2%20Voltímetros%20de%20valor%20eficaz%20(True%20RMS))


---
## 1.1. Clasificaciones
- Mediciones directas
  _Cuando la magnitud se mide directamente_
- Mediciones indirectas
  _Cuando la magnitud se obtiene a través de un cálculo que involucra la medición_
- Métodos de comparación
  _Cuando se hace un circuito que compara magnitudes y se mide sin modificar nada_
- Métodos de sustitución
  _Cuando se hace un circuito que compara magnitudes y luego se modifica el circuito para cambiar las magnitudes y volver a medir_
- Error de inserción:
![[D4-2022-1-1.pdf#page=6&rect=397,165,678,463|D4-2022-1-1, p.6]]
![[D4-2022-1-1.pdf#page=6&rect=154,75,495,154|D4-2022-1-1, p.6]]
![[D4-2022-1-1.pdf#page=7&rect=244,258,464,288|D4-2022-1-1, p.7]]
Si se cumple $e_{inserción} < \frac{e_{fortuito}}{10}$

---

## 1.2. Método de oposición
![[D4-2022-1-1.pdf#page=8&rect=20,64,702,494|D4-2022-1-1, p.8]]

### 1.2.1. Explicación
Se quiere medir una tensión $U_{x}$, pero como ya se sabe, la impedancia interna de la fuente hace que varíe la tensión medida, debido a la caída de tensión de la resistencia interna de la fuente.
La idea del método es hacer que otra fuente externa "suministre energía al instrumento de medición", de esta manera medimos "al vacío". 
Para poder generar la tensión que se opone, se dispone de $R_{1}$ y $R_{2}$ que se pueden regular para generar dicha tensión. Además una vez que se emplee el detector para ver que no hay corriente en la rama de la fuente que se quiere medir, se puede emplear la corriente medida en $R_{2}$ para calcular y medir de manera indirecta la tensión deseada.

Los errores presentes son: 
- El error fortuito debido al amperímetro empleado.
- El error fortuito de la resistencia de medición.
- El error de insensibilidad del detector, ya que este solo puede detectar hasta cierto "punto".

![[D4-2022-1-1.pdf#page=9&rect=122,31,449,124|D4-2022-1-1, p.9]]
Teniendo en cuenta las variaciones de tensión en el detector se puede calcular de esta forma el error de insensibilidad.


---

## 1.3. Método del voltímetro diferencial

![[D4-2022-1-1.pdf#page=10&rect=73,237,652,503|D4-2022-1-1, p.10]]

Esta es bastante mala porque se mide una diferencia, y como se vió en la teoría, las mediciones diferenciales tienen propagación de errores que se incrementan cuando la diferencia es pequeña.

### 1.3.1. Pero si se hace un pequeño ajuste, se mejora mucho

![[D4-2022-1-1.pdf#page=11&rect=44,65,657,511|D4-2022-1-1, p.11]]

---

## 1.4. Método del voltímetro amperímetro

Se emplea para medir una resistencia

### 1.4.1. Conexión corta

![[D4-2022-1-1.pdf#page=13&rect=57,76,683,498|D4-2022-1-1, p.13]]

### 1.4.2. Conexión larga

![[D4-2022-1-1.pdf#page=14&rect=34,59,680,506|D4-2022-1-1, p.14]]

### 1.4.3. IMPORTANTE: criterio para elegir entre la conexión corta o la conexión larga

El criterio se hace a partir de definir la resistencia crítica: $X_{c} = \sqrt{R_{A}*R_{V}}$
- Si $X<X_{C}$ entonces hay que hacer conexión **CORTA**.
- Si $X>X_{C}$ entonces hay que hacer conexión **LARGA**.

---

# 2. Resistores de muy alto valor

Se quiere medir la corriente que pasa por el resistor, pero se terminan sumando corriente que pasan por el aislante en el que está montada la resistencia.

![[D5-2022-1.pdf#page=1&rect=163,101,555,387|D5-2022-1, p.1]]![[D5-2022-1.pdf#page=5&rect=167,15,553,521|D5-2022-1, p.5]]
---
# 3. Resistores de muy bajo valor

La idea es desafectar Rc13 y Rc42 de la medición, haciendo que la conexión del voltímetro, esté en el punto 3 y 4, esto se logra haciendo la conexión física de manera diferente, las conexiones de corriente se hacen de la parte inferior en el diagrama de abajo:

![[D5-2022-1.pdf#page=9&rect=49,44,684,485|D5-2022-1, p.9]]

---
# 4. Método de Wheatstone
Se emplea para medir resistencias

![[D5-2022-1.pdf#page=16&rect=15,60,710,533|D5-2022-1, p.16]]

---
# 5. Digital vs Analógico

![[D6-2022-1.pdf#page=1&rect=37,71,693,496|D6-2022-1, p.1]]

![[D6-2022-1.pdf#page=3&rect=22,300,706,485|D6-2022-1, p.3]]

## 5.2 Conversor de doble rampa

![[D6-2022-1.pdf#page=28&rect=46,108,654,501|D6-2022-1, p.28]]

![[D6-2022-1.pdf#page=33&rect=28,24,699,499|D6-2022-1, p.33]]

---
# 6. Parámetros importantes de las señales en mediciones digitales

- Factor de Forma de Onda (FFO)
 $FFO=\frac{U_{ef}}{\hat{U}_{\frac{1}{2}Ciclo}}$ 
 - Factor de Cresta (FC) 
$FC=\frac{U_{max}}{U_{ef}}$


### 6.1 Voltímetros de valor medio

![[D7-2022-1.pdf#page=15&rect=18,57,710,486|D7-2022-1, p.15]]

![[D7-2022-1.pdf#page=16&rect=107,181,654,279|D7-2022-1, p.16]]

### 6.1.1 Error de Factor de Forma de Onda

![[D7-2022-1.pdf#page=20&rect=25,38,667,494|D7-2022-1, p.20]]
### 6.2 Voltímetros de valor eficaz (True RMS)

