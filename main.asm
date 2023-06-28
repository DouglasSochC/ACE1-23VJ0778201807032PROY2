; *********************
; D = Definicion
; Params = Parametros
; *********************

; RECORDAR: Si modificamos la direccion del segmento de datos, ya no podremos obtener
; nuestros array de bytes definidos abajo de .DATA, por lo tanto hay guardar la direccion del
; segmento de datos original

; D: Pausa la ejecucion del programa hasta que el usuario presione ENTER
mPausaE MACRO
  MOV AH, 0AH
  INT 21H
ENDM

; S: Se encarga de determinar el color de un pixel que esta ubicado en un sprite, para esto es necesario utilizar los registros AX (x) y BX (y). El color encontrado se almacena en la variable 'aux_color_pixel'
; codigo_sprite: Es el codigo de sprite que se esta escogiendo para pintar el bloque
mAuxColorPosSprite MACRO codigo_sprite

  LOCAL L_VACIO, L_PARED, L_SUELO, L_JUGADOR, L_CAJA_OBJETIVO, L_OBJETIVO, L_COLOR, L_FLECHA, L_CAJA_SIN_OBJETIVO, L_FIN

  PUSH AX
  PUSH BX

  CMP codigo_sprite, 01H
  JE L_PARED

  CMP codigo_sprite, 02H
  JE L_SUELO

  CMP codigo_sprite, 03H
  JE L_JUGADOR

  CMP codigo_sprite, 04H
  JE L_CAJA_OBJETIVO

  CMP codigo_sprite, 05H
  JE L_OBJETIVO

  CMP codigo_sprite, 06H
  JE L_FLECHA

  CMP codigo_sprite, 07H
  JE L_CAJA_SIN_OBJETIVO

  L_VACIO:
    MOV SI, offset sprite_vacio
  JMP L_COLOR

  L_PARED:
    MOV SI, offset sprite_pared
  JMP L_COLOR

  L_SUELO:
    MOV SI, offset sprite_suelo
  JMP L_COLOR

  L_CAJA_OBJETIVO:
    MOV SI, offset sprite_caja_objetivo
  JMP L_COLOR

  L_JUGADOR:
    MOV SI, offset sprite_jugador
  JMP L_COLOR

  L_OBJETIVO:
    MOV SI, offset sprite_objetivo
  JMP L_COLOR

  L_FLECHA:
    MOV SI, offset sprite_flecha
  JMP L_COLOR

  L_CAJA_SIN_OBJETIVO:
    MOV SI, offset sprite_caja_sin_objetivo
  JMP L_COLOR

  L_COLOR:
    ; Se realiza el calculo de x * 8 y el resultado se obtiene el registro AX
    MOV DX, 08H
    MUL DX
    ; Se realiza el calculo de AX + y para posicionar el indice de lectura. Hay que recordar que el resultado se mantiene en AX
    ADD AX, BX
    ADD SI, AX
    ; Se obtiene el color
    MOV AX, 00H
    MOV AL, [SI]
    MOV aux_color_pixel, AL

  L_FIN:
    POP BX
    POP AX

ENDM

; D: Se encarga de pintar un pixel en un lienzo de 320 x 200 ; Para realizar el pintado se aplica la siguiente ecuacion para hallar la posicion en memoria (x + 320y)
; x: Fila del lienzo (Maximo 320 pixeles)
; y: Columna del lienzo (Maximo 200 pixeles)
; color: Codigo del color a pintar en el pixel
mPintarPixel MACRO x, y, color

  ; Se inicializan las variables a utilizar para el pintado de un pixel
  MOV aux_pos_x_pixel, x
  MOV aux_pos_y_pixel, y

  ; Se inicializan los registros a utilizar
  MOV AX, 0000H
  MOV BX, 0000H

  ; Calculo de 320 * x
  MOV AX, aux_pos_x_pixel
  MOV BX, 140H
  MUL BX

  ; Calculo de y + 320 * x
  ADD AX, aux_pos_y_pixel

  ; Se almacena el color
  MOV BL, color

  ; Se almacena la posicion del segmento de datos
  PUSH DS

  ; Se posiciona el registro DS para empezar a definir el color de un pixel
  MOV DX, 0A000H
  MOV DS, DX

  ; Se posiciona el apuntador en la posicion calculada anteriormente
  MOV SI, AX

  ; Se setea el color
  MOV [SI], BL

  ; Se recupera la posicion del segmento de datos
  POP DS

ENDM

; D: Se encarga de pintar un sprite de 8x8 pixeles
; pos: Representa la posicion entre 0 a 1000 debido a que el lienzo es de 40 x 25 = 1000
; codigo_sprite: Es el sprite a pintar en la posicion indicada
mPintarSprite MACRO pos, codigo_sprite

  LOCAL L_FILA, L_COLUMNA

  ; Se inicializan las variables a utilizar
  MOV aux_pos_x_sprite, 0000H
  MOV aux_pos_y_sprite, 0000H

  ; Se inicializan los registros a utilizar
  MOV AX, 0000H
  MOV BX, 0000H
  MOV CX, 0000H
  MOV DX, 0000H

  ; Se dividira la posicion en 40 (28H) para obtener el cociente en AX (fila) y el residuo en DX (columna)
  MOV AX, pos
  MOV BX, 28H
  DIV BX

  ; Se setean los valores obtenidos para la fila y columna
  MOV aux_pos_x_sprite, AX
  MOV aux_pos_y_sprite, DX

  ; Se multiplica la fila por 8 (08H) para obtener la fila inicial de pixeles a pintar
  MOV AX, aux_pos_x_sprite
  MOV BX, 08H
  MUL BX
  MOV aux_pos_x_sprite, AX

  ; Se multiplica la columna por 8 (08H) para obtener la columna inicial de pixeles a pintar
  MOV AX, aux_pos_y_sprite
  MOV BX, 08H
  MUL BX
  MOV aux_pos_y_sprite, AX

  ; Se inicializa la cantidad de filas que va a dibujar
  MOV AX, 00H
  L_FILA:
    PUSH AX

    ; Se inicializa la cantidad de columnas que va a dibujar
    MOV BX, 00H
    L_COLUMNA:
      PUSH BX ; Se almacena temporalmente el indice de la columna
      PUSH AX ; Se almacena temporalmente el indice de la fila
      mAuxColorPosSprite codigo_sprite ; Se determina el color del pixel a pintar

      ADD AX, aux_pos_x_sprite ; Se realiza el corrimiento de pintado por parte de la columna
      ADD BX, aux_pos_y_sprite ; Se realiza el corrimiento de pintado por parte de la fila
      mPintarPixel AX, BX, aux_color_pixel

      POP AX
      POP BX
    INC BX
    CMP BX, 08H
    JNZ L_COLUMNA

    POP AX
  INC AX
  CMP AX, 08H
  JNZ L_FILA

ENDM

; D: Se encarga de dibujar en el lienzo (40 x 25) los sprite segun los codigos contenidos en la variable 'lienzo'
mPintarLienzo MACRO

  LOCAL L_LECTURA

  ; Se inicializan los parametros auxiliares
  MOV aux_iteracion_sprite, 0000H
  MOV aux_codigo_sprite, 00H

  ; Se inicializan los registros a utilizar
  MOV AX, 0000H

  ; Se obtiene la variable 'lienzo' para empezarla a leer y colorear un bloque de pixeles
  MOV DI, offset lienzo

  ; Realizara la lectura de cada byte que contiene el 'lienzo'
  L_LECTURA:

    PUSH aux_iteracion_sprite ; Se almacena el indice del primer ciclo para la obtencion del color del 'lienzo'
    PUSH DI

    MOV AL, [DI] ; Se obtiene el codigo del sprite que esta en el lienzo
    MOV aux_codigo_sprite, AL ; Se setea el codigo en la variable auxiliar que maneja el codigo del sprite
    mPintarSprite aux_iteracion_sprite, aux_codigo_sprite ; Se pinta el sprite

    POP DI
    INC DI
    POP aux_iteracion_sprite ; Se recupera el indice del primer ciclo

  INC aux_iteracion_sprite
  CMP aux_iteracion_sprite, 03E8H ; Se realizara el ciclo hasta la iteracion 1000 (03E8H) debido a que 40 x 25 = 1000
  JNZ L_LECTURA

ENDM

; D: Se encarga de pintar la pantalla con el sprite vacio
mLimpiarPantalla MACRO

  LOCAL L_CICLO

  ; Inicializando variables a utilizar
  MOV aux_iteracion_sprite, 0000H
  MOV aux_codigo_sprite, 00H

  ; Realizara el ciclo durante las 1000 posiciones (40 x 25)
  L_CICLO:

    PUSH aux_iteracion_sprite ; Se almacena el indice del primer ciclo para la obtencion del color del 'lienzo'
    mPintarSprite aux_iteracion_sprite, aux_codigo_sprite ; Se pinta el bloque del lienzo en la posicion que nos da CX
    POP aux_iteracion_sprite ; Se recupera el indice del primer ciclo

  INC aux_iteracion_sprite
  CMP aux_iteracion_sprite, 03E8H ; Se realizara el ciclo hasta la iteracion 1000 (03E8H) debido a que 40 x 25 = 1000
  JNZ L_CICLO

ENDM

; D: Se encarga de setear un sprite de una posicion a otra dentro del lienzo. Este actualiza el valor que posee el parametro 'pos_actual' a la nueva posicion
; pos_actual: Posicion actual del sprite
; cod_sprite: Es el codigo del sprite que se va a reubicar
; REGISTRO AH: Indica si es una suma o resta (00H = Suma ; 01H = Resta)
; REGISTRO AL: Es el valor a sumar o restar con respecto a la posicion actual
mReubicarSpriteEnLienzo MACRO pos_actual, cod_sprite

  LOCAL L_SUMA, L_RESTA, L_REUBICAR, L_SALIDA

  ; Se realiza la limpieza del sprite en los graficos
  PUSH AX
  MOV aux_codigo_sprite, 02H ; Se setea el sprite a utilizar
  mPintarSprite pos_actual, aux_codigo_sprite ; Se pinta el bloque del lienzo en la posicion indicada
  MOV SI, offset lienzo
  ADD SI, pos_actual
  MOV AL, aux_codigo_sprite
  MOV [SI], AL
  POP AX

  ; Se setea la posicion actual al sprite del suelo
  PUSH AX
  MOV SI, offset lienzo
  ADD SI, pos_actual
  MOV AH, 02H
  MOV [SI], AH
  POP AX

  ; Se determina el tipo de operacion a realizar
  CMP AH, 01H
  MOV AH, 00
  JE L_RESTA

  L_SUMA:
    ADD pos_actual, AX
    JMP L_REUBICAR

  L_RESTA:
    SUB pos_actual, AX

  L_REUBICAR:
    MOV SI, offset lienzo
    ADD SI, pos_actual
    MOV AL, cod_sprite
    MOV [SI], AL

  L_SALIDA:
    ; Se redibuja el sprite en los graficos segun la posicion nueva
    MOV aux_codigo_sprite, cod_sprite ; Se setea el sprite a utilizar
    mPintarSprite pos_actual, aux_codigo_sprite ; Se pinta el bloque del lienzo en la posicion indicada

ENDM

; D: Se encarga de setear un sprite en una posicion especifica.
; pos_actual: Posicion actual del sprite
; cod_sprite: Es el codigo del sprite que se va a reubicar
mPintarSpriteEnLienzo MACRO pos_actual, cod_sprite

  PUSH AX
  MOV cod_sprite, 05H ; Se setea el sprite a utilizar
  mPintarSprite pos_actual, cod_sprite ; Se pinta el bloque del lienzo en la posicion indicada
  MOV SI, offset lienzo
  ADD SI, pos_actual
  MOV AL, cod_sprite
  MOV [SI], AL
  POP AX

ENDM

; D: Se encarga de clasificar el tipo de movimiento que se va a a realizar para la interracion del jugador con los objetos
; pos_actual: Posicion actual del jugador
; REGISTRO AH: Indica si es una suma o resta (00H = Suma ; 01H = Resta)
; REGISTRO AL: Es el valor a sumar o restar con respecto a la posicion actual
mTipoMovimientoLienzo MACRO pos_actual

  LOCAL L_CLASIFICAR, L_PARED, L_SUELO, L_OBJETIVO, L_SALIDA

  ; Se almacenan los registros AX
  PUSH AX

  ; Se inicializa la variable que nos indica el tipo de movimiento
  MOV aux_tipo_movimiento, 00H

  ; Se determina el tipo de operacion a realizar
  CMP AH, 01H
  MOV AH, 00
  MOV BX, pos_actual
  JE L_RESTA

  L_SUMA:
    ADD BX, AX
    JMP L_CLASIFICAR

  L_RESTA:
    SUB BX, AX

  L_CLASIFICAR:
    MOV SI, offset lienzo
    ADD SI, BX
    MOV AX, 0000H
    MOV AL, [SI]
    MOV aux_tipo_movimiento, AL
    JMP L_SALIDA

  L_SALIDA:
    POP AX ; Se obtienen los registros AX almacenados al principo de la MACRO

ENDM

.MODEL SMALL
.RADIX 16
.STACK
.DATA

  ; **************************************
  ; ******* Auxiliares para MACROS *******
  ; **************************************

  ; Sprite
  aux_iteracion_sprite dw 0000H ; Indica la iteracion actual en el que se esta leyendo la variable 'sprite'
  aux_codigo_sprite db 00H ; Indica el codigo de sprite a utilizar para el pintado de un bloque de pixeles de 8x8
  aux_color_pixel db 00H ; Indica el color del pixel a pintar
  aux_pos_x_sprite dw 0000H ; Indica la posicion inicial de pintado de un bloque en una fila
  aux_pos_y_sprite dw 0000H ; Indica la posicion inicial de pintado de un bloque en una columna
  aux_pos_x_pixel dw 0000H ; Indica la posicion de pintado de un solo pixel en una fila
  aux_pos_y_pixel dw 0000H ; Indica la posicion de pintado de un solo pixel en una columna

  ; **************************************
  ; ****** Utilizados en ejecucion *******
  ; **************************************

  ; Informacion
  msg_nombre db "Nombre: Douglas Soch", "$"
  msg_carne db "Carne: 201807032", "$"
  msg_continuar db "Pulse cualquier boton para continuar", "$"

  ; Menu principal
  msg_iniciar_juego db "INICIAR JUEGO", "$"
  msg_cargar_nivel db "CARGAR NIVEL", "$"
  msg_configuracion db "CONFIGURACION", "$"
  msg_puntajes_altos db "PUNTAJES ALTOS", "$"
  msg_salir db "SALIR", "$"
  posicion_flecha dw 0000

  ; Lienzo
  ; lienzo db 03E8H dup(06H) ; Dimension 40 x 25 = 1000 posiciones
  lienzo  db  00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
          db  01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
          db  01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
          db  01H, 01H, 03H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 07H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 05H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 04H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 02H, 01H, 01H
          db  01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
          db  01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
          db  00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H

  ; Sprites
  ; Codigo 00H
  sprite_vacio    db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
                  db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
                  db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
                  db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
                  db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
                  db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
                  db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
                  db   00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H

  ; Codigo 01H
  sprite_pared    db   2AH, 2AH, 2AH, 2AH, 12H, 1FH, 2AH, 2AH
                  db   2AH, 2AH, 2AH, 2AH, 12H, 1FH, 2AH, 2AH
                  db   12H, 12H, 12H, 12H, 12H, 12H, 12H, 12H
                  db   12H, 1FH, 1FH, 1FH, 1FH, 1FH, 1FH, 1FH
                  db   12H, 1FH, 2AH, 2AH, 2AH, 2AH, 2AH, 2AH
                  db   12H, 1FH, 2AH, 2AH, 2AH, 2AH, 2AH, 2AH
                  db   12H, 12H, 12H, 12H, 12H, 12H, 12H, 12H
                  db   1FH, 1FH, 1FH, 1FH, 12H, 1FH, 1FH, 1FH

  ; Codigo 02H
  sprite_suelo    db   48H, 02H, 48H, 48H, 48H, 48H, 48H, 48H
                  db   48H, 48H, 48H, 48H, 48H, 02H, 48H, 48H
                  db   48H, 48H, 48H, 48H, 48H, 48H, 48H, 48H
                  db   02H, 48H, 48H, 02H, 48H, 48H, 02H, 48H
                  db   48H, 48H, 48H, 48H, 48H, 48H, 48H, 48H
                  db   48H, 48H, 48H, 02H, 48H, 48H, 48H, 48H
                  db   48H, 02H, 48H, 48H, 48H, 48H, 02H, 48H
                  db   48H, 48H, 48H, 48H, 48H, 48H, 48H, 48H

  ; Codigo 03H
  sprite_jugador  db   48H, 48H, 28H, 28H, 28H, 28H, 48H, 48H
                  db   48H, 48H, 28H, 28H, 28H, 48H, 28H, 48H
                  db   48H, 48H, 43H, 01H, 43H, 01H, 48H, 48H
                  db   48H, 48H, 43H, 43H, 06H, 06H, 48H, 48H
                  db   48H, 28H, 01H, 28H, 28H, 01H, 28H, 48H
                  db   48H, 43H, 01H, 01H, 01H, 01H, 43H, 48H
                  db   48H, 48H, 01H, 01H, 01H, 01H, 48H, 48H
                  db   48H, 48H, 06H, 48H, 48H, 06H, 48H, 48H

  ; Codigo 04H
  sprite_caja_objetivo  db   0B9H, 0B9H, 0B9H, 0B9H, 0B9H, 0B9H, 0B9H, 0B9H
                        db   0B9H, 006H, 006H, 006H, 006H, 006H, 006H, 0B9H
                        db   0B9H, 006H, 006H, 01BH, 018H, 006H, 006H, 0B9H
                        db   0B9H, 0B9H, 0B9H, 01BH, 018H, 0B9H, 0B9H, 0B9H
                        db   0B9H, 006H, 006H, 018H, 018H, 006H, 006H, 0B9H
                        db   0B9H, 006H, 006H, 006H, 006H, 006H, 006H, 0B9H
                        db   0B9H, 006H, 006H, 006H, 006H, 006H, 006H, 0B9H
                        db   0B9H, 0B9H, 0B9H, 0B9H, 0B9H, 0B9H, 0B9H, 0B9H

  ; Codigo 05H
  sprite_objetivo db   48H, 48H, 48H, 48H, 48H, 48H, 48H, 48H
                  db   48H, 48H, 41H, 41H, 41H, 41H, 48H, 48H
                  db   48H, 41H, 41H, 41H, 41H, 41H, 41H, 48H
                  db   48H, 41H, 41H, 41H, 41H, 41H, 41H, 48H
                  db   48H, 41H, 41H, 41H, 41H, 41H, 41H, 48H
                  db   48H, 41H, 41H, 41H, 41H, 41H, 41H, 48H
                  db   48H, 48H, 41H, 41H, 41H, 41H, 48H, 48H
                  db   48H, 48H, 48H, 48H, 48H, 48H, 48H, 48H
  ; Codigo 06H
  sprite_flecha db   00H, 00H, 00H, 0CH, 00H, 00H, 00H, 00H
                db   00H, 00H, 00H, 0CH, 0CH, 00H, 00H, 00H
                db   0CH, 0CH, 0CH, 0CH, 0CH, 0CH, 00H, 00H
                db   0CH, 0CH, 0CH, 0CH, 0CH, 0CH, 0CH, 00H
                db   0CH, 0CH, 0CH, 0CH, 0CH, 0CH, 0CH, 00H
                db   0CH, 0CH, 0CH, 0CH, 0CH, 0CH, 00H, 00H
                db   00H, 00H, 00H, 0CH, 0CH, 00H, 00H, 00H
                db   00H, 00H, 00H, 0CH, 00H, 00H, 00H, 00H

  ; Codigo 07H
  sprite_caja_sin_objetivo  db   0C7H, 0C7H, 0C7H, 0C7H, 0C7H, 0C7H, 0C7H, 0C7H
                            db   0C7H, 07EH, 07EH, 07EH, 07EH, 07EH, 07EH, 0C7H
                            db   0C7H, 07EH, 07EH, 01BH, 018H, 07EH, 07EH, 0C7H
                            db   0C7H, 0C7H, 0C7H, 01BH, 018H, 0C7H, 0C7H, 0C7H
                            db   0C7H, 07EH, 07EH, 018H, 018H, 07EH, 07EH, 0C7H
                            db   0C7H, 07EH, 07EH, 07EH, 07EH, 07EH, 07EH, 0C7H
                            db   0C7H, 07EH, 07EH, 07EH, 07EH, 07EH, 07EH, 0C7H
                            db   0C7H, 0C7H, 0C7H, 0C7H, 0C7H, 0C7H, 0C7H, 0C7H

  ; Juego
  nivel_juego db 00H ; Representa el nivel del juego actual
  posicion_jugador dw 007AH ; Representa la posicion actual del jugador de forma lineal (1000 posiciones)
  aux_pos_jugador_anterior dw 0000H ; Almacena la posicion que tenia anteriormente el jugador antes de realizar un movimiento
  aux_tipo_movimiento db 00H ; Almacena el tipo de movimiento que realizara el jugador al momento de presionar algun boton
  aux_cantidad_objetivos db 00H ; Almacena la cantidad de objetivos en el cual el usuario a estado encima

  ; Controles
  control_arriba    db  48H
  control_abajo     db  50H
  control_izquierda db  4BH
  control_derecha   db  4DH
  control_salida    db  3CH

.CODE
.STARTUP

  MODO_VIDEO PROC
    ; Se cambia el modo de video
    MOV AH, 00
    MOV AL, 13
    INT 10
  MODO_VIDEO ENDP

  PANTALLA_INICIAL PROC

    mLimpiarPantalla

    ; Posicionando cursor para dibujar el nombre
    MOV DL, 0AH
		MOV DH, 09H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto
    PUSH DX
    MOV DX, offset msg_nombre
		MOV AH, 09
		INT 21
    POP DX

    ; Posicionando cursor para dibujar el carnet
    MOV DL, 0CH
    ADD DH, 02H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto
    PUSH DX
    MOV DX, offset msg_carne
		MOV AH, 09
		INT 21
    POP DX

    ; Posicionando cursor para dibujar el boton para presionar
    MOV DL, 02H
    ADD DH, 02H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto
    PUSH DX
    MOV DX, offset msg_continuar
		MOV AH, 09
		INT 21
    POP DX

    ; Se espera hasta que el usuario oprima algun boton del teclado
    MOV AH, 00
		INT 16

  PANTALLA_INICIAL ENDP

  MENU_PRINCIPAL PROC

    mLimpiarPantalla

    ; Posicionando cursor para dibujar la opcion 'INICIAR JUEGO'
    MOV DL, 0CH
		MOV DH, 07H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto de inicio de juego
    PUSH DX
    MOV DX, offset msg_iniciar_juego
		MOV AH, 09
		INT 21
    POP DX

    ; Posicionando cursor para dibujar la opcion 'CARGAR NIVEL'
    MOV DL, 0CH
    ADD DH, 02H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto de carga de nivel
    PUSH DX
    MOV DX, offset msg_cargar_nivel
		MOV AH, 09
		INT 21
    POP DX

    ; Posicionando cursor para dibujar la opcion 'CONFIGURACION'
    MOV DL, 0CH
    ADD DH, 02H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto de configuracion
    PUSH DX
    MOV DX, offset msg_configuracion
		MOV AH, 09
		INT 21
    POP DX

    ; Posicionando cursor para dibujar la opcion 'PUNTAJES ALTOS'
    MOV DL, 0CH
    ADD DH, 02H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto de configuracion
    PUSH DX
    MOV DX, offset msg_puntajes_altos
		MOV AH, 09
		INT 21
    POP DX

    ; Posicionando cursor para dibujar la opcion 'SALIR'
    MOV DL, 0CH
    ADD DH, 02H
		MOV BH, 00H
		MOV AH, 02H
		INT 10H

    ; Imprimiendo el texto de salida
    PUSH DX
    MOV DX, offset msg_salir
		MOV AH, 09
		INT 21
    POP DX

    JMP ENTRADA_MENU_PRINCIPAL

  MENU_PRINCIPAL ENDP

  JUEGO PROC
    ; Se pinta la informacion que contiene el lienzo
    mPintarLienzo
    ; Se recibe la entrada por medio del teclado
    @@interaccion:
      call MOVIMIENTO_JUGADOR
    JMP @@interaccion
  JUEGO ENDP

  CARGAR_NIVEL PROC
  CARGAR_NIVEL ENDP

  CONFIGURACION PROC
  CONFIGURACION ENDP

  PUNTAJES_ALTOS PROC
  PUNTAJES_ALTOS ENDP

  ENTRADA_MENU_PRINCIPAL PROC

    ; Para determinar la posicion de escritura de la flecha se utilizara la siguiente ecuacion 290 + 80n
    MOV AX, 50H ; 80
    MOV BX, posicion_flecha ; n
    MUL BX ; 80n
    ADD AX, 122H ; 290 + 80n
    MOV aux_iteracion_sprite, AX

    MOV aux_codigo_sprite, 06H ; Se setea el sprite a utilizar
    mPintarSprite aux_iteracion_sprite, aux_codigo_sprite ; Se pinta el bloque del lienzo en la posicion que nos da CX

    ; Se espera hasta que el usuario oprima algun boton del teclado
    MOV AH, 00
		INT 16

    ; Presiono la tecla de flecha hacia arriba
    CMP AH, 48H
		JE @@hacia_arriba

    ; Presiono la tecla de flecha hacia abajo
		CMP AH, 50H
		JE @@hacia_abajo

    ; Presiono la tecla F1
		CMP AH, 3BH
		JE @@opcion_seleccionada
    JMP @@repetir

    @@hacia_arriba:
      ; Se limpia la posicion actual de la flecha
      MOV aux_codigo_sprite, 00H ; Se setea el sprite a utilizar
      mPintarSprite aux_iteracion_sprite, aux_codigo_sprite ; Se pinta el bloque del lienzo en la posicion indicada

      ; Se verifica si se sobrepasa la posicion 04H al sumar una posicion mas a la flecha
      MOV AX, posicion_flecha
      DEC AX
      CMP AX, 00H
      JL @@repetir

      ; Se decrementa la posicion de la flecha
      DEC posicion_flecha
    JMP @@repetir

    @@hacia_abajo:

      ; Se limpia la posicion actual de la flecha
      MOV aux_codigo_sprite, 00H ; Se setea el sprite a utilizar
      mPintarSprite aux_iteracion_sprite, aux_codigo_sprite ; Se pinta el bloque del lienzo en la posicion indicada

      ; Se verifica si se sobrepasa la posicion 04H al sumar una posicion mas a la flecha
      MOV AX, posicion_flecha
      INC AX
      CMP AX, 04H
      JG @@repetir

      ; Se incrementa la posicion de la flecha
      INC posicion_flecha
    JMP @@repetir

    @@opcion_seleccionada:
      CMP posicion_flecha, 00H
      JE JUEGO
      CMP posicion_flecha, 01H
      JE CARGAR_NIVEL
      CMP posicion_flecha, 02H
      JE CONFIGURACION
      CMP posicion_flecha, 03H
      JE PUNTAJES_ALTOS
      CMP posicion_flecha, 04H
      JE SALIR

    @@repetir:
		  JMP ENTRADA_MENU_PRINCIPAL

  ENTRADA_MENU_PRINCIPAL ENDP

  MOVIMIENTO_JUGADOR:

    ; Se comprueba si hay una tecla disponible para leer sin bloquear la ejecucion del programa
    MOV AH, 01
		INT 16
		JZ @@fin_entrada_juego ; No se leyo nada en el buffer de entrada

    ; Espera hasta que se presione una tecla; la tecla presionada se queda en AH
    MOV AH, 00
		INT 16

    ; Se verifica el boton presionado
		CMP AH, [control_arriba]
		JE @@mov_arriba
		CMP AH, [control_abajo]
		JE @@mov_abajo
		CMP AH, [control_izquierda]
		JE @@mov_izquierda
		CMP AH, [control_derecha]
		JE @@mov_derecha
    JMP @@fin_entrada_juego
    CMP AH, [control_salida]
    JE MENU_PRINCIPAL

    @@mov_arriba:
      MOV AH, 01H
      MOV AL, 28H
      JMP @@movimiento

    @@mov_abajo:
      MOV AH, 00H
      MOV AL, 28H
      JMP @@movimiento

    @@mov_izquierda:
      MOV AH, 01H
      MOV AL, 01H
      JMP @@movimiento

    @@mov_derecha:
      MOV AH, 00H
      MOV AL, 01H
      JMP @@movimiento

    @@movimiento:
      mTipoMovimientoLienzo posicion_jugador
      CMP aux_tipo_movimiento, 01H
      JE @@mov_pared
      CMP aux_tipo_movimiento, 02H
      JE @@mov_suelo
      CMP aux_tipo_movimiento, 05H
      JE @@objetivo
      JMP @@fin_entrada_juego

    @@mov_pared:
      JMP @@fin_entrada_juego

    @@mov_suelo:
      MOV BX, posicion_jugador
      MOV aux_pos_jugador_anterior, BX
      mReubicarSpriteEnLienzo posicion_jugador, 03H

      ; Revisar si en la posicion donde estaba anteriormente existio un objetivo
      CMP aux_cantidad_objetivos, 00H
      JE @@fin_entrada_juego

      ; Se repinta el objetivo en el caso que ya existia una anteriormente
      MOV aux_codigo_sprite, 05H
      mPintarSpriteEnLienzo aux_pos_jugador_anterior, aux_codigo_sprite
      DEC aux_cantidad_objetivos
      JMP @@fin_entrada_juego

    @@objetivo:
      MOV BX, posicion_jugador
      MOV aux_pos_jugador_anterior, BX

      mReubicarSpriteEnLienzo posicion_jugador, 03H
      INC aux_cantidad_objetivos

      ; Revisar si en la posicion donde estaba anteriormente existio un objetivo
      CMP aux_cantidad_objetivos, 01H
      JLE @@fin_entrada_juego

      ; Se repinta el objetivo en el caso que ya existia una anteriormente
      MOV aux_codigo_sprite, 05H
      mPintarSpriteEnLienzo aux_pos_jugador_anterior, aux_codigo_sprite
      DEC aux_cantidad_objetivos
      JMP @@fin_entrada_juego

    ; @@mov_caja_sin_obj:
    ;   JMP @@fin_entrada_juego

    ; @@mov_caja_con_obj:
    ;   JMP @@fin_entrada_juego

    @@fin_entrada_juego:
  RET

  SALIR PROC
    mLimpiarPantalla
  SALIR ENDP

  FIN PROC
    .EXIT
  FIN ENDP

END