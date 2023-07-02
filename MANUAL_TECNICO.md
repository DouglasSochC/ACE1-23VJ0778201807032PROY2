### Universidad de San Carlos de Guatemala
### Escuela de Ingeniería en Ciencias y Sistemas
### Facultad de Ingeniería
### Arquitectura de Computadoras y Ensambladores 1
### 1er. Semestre 2023

#### Desarrollador:

201807032 - Douglas Alexander Soch Catalán

## Descripcion

El siguiente prototipo es un juego sencillo empleando las características gráficas que brinda DOS y el conjunto de interrupciones que este provee.

El juego a desarrollar es el juego japonés Sokoban, en el cual el jugador tiene como principal objetivo empujar una serie de cajas hasta conseguir que éstas se ubiquen en ciertas posiciones. Cuando el jugador consigue lo anterior se le permite avanzar de nivel y acumular más puntos.

### Contenido

- Requisitos
- Implementación del codigo
    - Configuración
    - Util
    - Encabezado
    - Menu Principal
        - Iniciar juego
        - Cargar nivel
        - Configuracion
        - Puntajes Altos
        - Salir

## Requisitos

* DOSbox  0.74-3
* Lenguaje ensamblador - MASM 6.11

## Implementacion del codigo

### Util

Para facilitar la lectura del codigo se ha realizado MACROS los cuales nos permiten leer y mantener un codigo más entendible para el desarrollador. Por lo tanto las MACROS desarrolladas son las siguientes:

```assembly
; S: Se encarga de determinar el color de un pixel que esta ubicado en un sprite, para esto es necesario utilizar los registros AX (x) y BX (y). El color encontrado se almacena en la variable 'aux_color_pixel'
; codigo_sprite: Es el codigo de sprite que se esta escogiendo para pintar el bloque
mAuxColorPosSprite MACRO codigo_sprite
```

```assembly
; Se encarga de limpiar toda la consola
mLimpiarC MACRO
```

```assembly
; D: Se encarga de pintar un pixel en un lienzo de 320 x 200 ; Para realizar el pintado se aplica la siguiente ecuacion para hallar la posicion en memoria (x + 320y)
; x: Fila del lienzo (Maximo 320 pixeles)
; y: Columna del lienzo (Maximo 200 pixeles)
; color: Codigo del color a pintar en el pixel
mPintarPixel MACRO x, y, color
```

```assembly
; D: Se encarga de pintar un sprite de 8x8 pixeles
; pos: Representa la posicion entre 0 a 1000 debido a que el lienzo es de 40 x 25 = 1000
; codigo_sprite: Es el sprite a pintar en la posicion indicada
mPintarSprite MACRO pos, codigo_sprite
```

```assembly
; D: Se encarga de dibujar en el lienzo (40 x 25) los sprite segun los codigos contenidos en la variable 'lienzo'
mPintarLienzo MACRO
```

```assembly
; D: Se encarga de pintar la pantalla con el sprite vacio
mLimpiarPantalla MACRO
```

```assembly
; D: Se encarga de setear un sprite de una posicion a otra dentro del lienzo. Este actualiza el valor que posee el parametro 'pos_actual' a la nueva posicion
; pos_actual: Posicion actual del sprite
; cod_sprite: Es el codigo del sprite que se va a reubicar
; REGISTRO AH: Indica si es una suma o resta (00H = Suma ; 01H = Resta)
; REGISTRO AL: Es el valor a sumar o restar con respecto a la posicion actual
mReubicarSpriteEnLienzo MACRO pos_actual, cod_sprite
```

```assembly
; D: Se encarga de setear un sprite en una posicion especifica.
; pos_actual: Posicion actual del sprite
; cod_sprite: Es el codigo del sprite que se va a reubicar
mPintarSpriteEnLienzo MACRO pos_actual, cod_sprite
```

```assembly
; D: Se encarga de clasificar el tipo de movimiento que se va a a realizar para la interracion del jugador con los objetos
; pos_actual: Posicion actual del jugador
; REGISTRO AH: Indica si es una suma o resta (00H = Suma ; 01H = Resta)
; REGISTRO AL: Es el valor a sumar o restar con respecto a la posicion actual
mTipoMovimientoLienzo MACRO pos_actual
```

### Configuración

Para el desarrollo de esta aplicación se ha utilizado la base hexadecimal (.RADIX 16), además se ha modificado el modo de video para visualizar la interfaz de Dosbox el cual se ha escogido la interrupción INT 10 y la opción 13H, en el cual nos da un lienzo de 320 x 200 pixeles.

### Encabezado

El desarrollo del encabezado se da en el PROC PANTALLA_INICIAL, este contiene toda la información del encabezado.

### Iniciar juego

El desarrollo de esta opción se da en el procedimiento JUEGO. La idea es que primero se leea el nivel a mostrar y posteriormente se empiece a escuchar las teclas presionadas por parte del usuario.

### Cargar nivel

Para el desarrollo de esta opción se tuvo que haber utilizado el procedimiento de CARGAR_NIVEL.

#### Configuración

Esta opción esta contenida en el procedimiento CONFIGURACION, en el cual primero muestra toda la información disponible de la interfaz y posteriormente se empieza a escuchar las teclas que presiona el usuario.

#### Puntajes altos

Para el desarrollo de esta opción se tuvo que haber utilizado el procedimiento de PUNTAJES_ALTOS.

#### Salir

Para la opción de salir se utilizó el procedimiento SALIR
