; *********************
; D = Definicion
; Params = Parametros
; *********************

; S: Pausa
; D: Pausa la ejecucion del programa hasta que el usuario presione ENTER
mPausaE MACRO
  MOV AH, 0AH
  INT 21H
ENDM

; D: Se encarga de pintar un pixel en un lienzo de 320 x 200 ; Para realizar el pintado se aplica la siguiente ecuacion para hallar la posicion en memoria (x + 320y)
; x: Fila del lienzo (Maximo 320 pixeles)
; y: Columna del lienzo (Maximo 200 pixeles)
; color: Codigo del color a pintar en el pixel
mPintarPixel MACRO x, y, color

  ; Se inicializan las variables a utilizar para el pintado de un pixel
  MOV aux_coord_x_sprite, x
  MOV aux_coord_y_sprite, y

  ; Se inicializan los registros a utilizar
  MOV AX, 0000H
  MOV BX, 0000H

  ; Calculo de 320 * x
  MOV AX, aux_coord_x_sprite
  MOV BX, 140H
  MUL BX

  ; Calculo de y + 320 * x
  ADD AX, aux_coord_y_sprite

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
  MOV AL, BL
  MOV [SI], AL

  ; Se recupera la posicion del segmento de datos
  POP DS

ENDM

; D: Se encarga de pintar un bloque de 8x8
; pos: Representa la posicion entre 0 a 1000 debido a que el lienzo es de 40 x 25 = 1000
; color: Codigo del color a pintar en el pixel
mPintarBloque MACRO pos, color

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

      ADD AX, aux_pos_x_sprite ; Se realiza el corrimiento de pintado por parte de la columna
      ADD BX, aux_pos_y_sprite ; Se realiza el corrimiento de pintado por parte de la fila
      mPintarPixel AX, BX, color

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

; D: Se encarga de dibujar en el lienzo de 320 x 200 los colores contenidos en la variable 'sprite'
mPintarSprite MACRO lienzo

  LOCAL L_LECTURA

  ; Se inicializan los parametros auxiliares
  MOV aux_iteracion_sprite, 0000H
  MOV aux_color_sprite, 00H

  ; Se inicializan los registros a utilizar
  MOV AX, 0000H

  ; Se obtiene la variable 'lienzo' para empezarla a leer y colorear un bloque de pixeles
  MOV DI, offset lienzo

  ; Realizara la lectura de cada byte que contiene el 'lienzo'
  L_LECTURA:

    PUSH aux_iteracion_sprite ; Se almacena el indice del primer ciclo para la obtencion del color del 'lienzo'
    PUSH DI

    MOV AL, [DI] ; Se obtiene el color del lienzo
    MOV aux_color_sprite, AL ; Se setea el color en la variable auxiliar que maneja el color a pintar
    mPintarBloque aux_iteracion_sprite, aux_color_sprite ; Se pinta el bloque del lienzo en la posicion que nos da CX

    POP DI
    INC DI
    POP aux_iteracion_sprite ; Se recupera el indice del primer ciclo

  INC aux_iteracion_sprite
  CMP aux_iteracion_sprite, 03E8H ; Se realizara el ciclo hasta la iteracion 1000 (03E8H) debido a que 40 x 25 = 1000
  JNZ L_LECTURA

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
  aux_color_sprite db 00H ; Indica el color del pixel a pintar
  aux_pos_x_sprite dw 0000H ; Indica la posicion inicial de pintado de un bloque en una fila
  aux_pos_y_sprite dw 0000H ; Indica la posicion inicial de pintado de un bloque en una columna
  aux_coord_x_sprite dw 0000H ; Indica la posicion de pintado de un solo pixel en una fila
  aux_coord_y_sprite dw 0000H ; Indica la posicion de pintado de un solo pixel en una columna

  ; **************************************
  ; ****** Utilizados en ejecucion *******
  ; **************************************

  ; Sprite
  ; sprite db 03E8H dup(06H) ; Dimension 40 x 25 = 1000 posiciones

  nivel_1  db  00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  16H, 16H, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 0AH, 16H, 16H
          db  00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H

.CODE
.STARTUP

  ; RECORDAR: Si modificamos la direccion del segmento de datos, ya no podremos obtener
  ; nuestros array de bytes definidos abajo de .DATA, por lo tanto hay guardar la direccion del
  ; segmento de datos original
  MODO_VIDEO PROC

    ; Se cambia el modo de video
    MOV AH, 00
    MOV AL, 13
    INT 10

    ; Se pinta el sprite
    mPintarSprite nivel_1
    mPausaE
    mPausaE

  MODO_VIDEO ENDP

.EXIT
END