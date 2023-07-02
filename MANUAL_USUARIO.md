### Universidad de San Carlos de Guatemala
### Escuela de Ingeniería en Ciencias y Sistemas
### Facultad de Ingeniería
### Arquitectura de Computadoras y Ensambladores 1
### Escuela de vacaciones - 1er. Semestre 2023

## Descripcion

El siguiente prototipo es un juego sencillo empleando las características gráficas que brinda DOS y el conjunto de interrupciones que este provee.

El juego a desarrollar es el juego japonés Sokoban, en el cual el jugador tiene como principal objetivo empujar una serie de cajas hasta conseguir que éstas se ubiquen en ciertas posiciones. Cuando el jugador consigue lo anterior se le permite avanzar de nivel y acumular más puntos.

### Contenido

- Requisitos
- Interfaz
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

## Interfaz

Se le brindarán al usuario una serie de menús para que pueda acceder a cada una de las funcionalidades disponibles para el juego.

## Encabezado

El programa, antes de cualquier cosa, muestra un encabezado indicando la información del desarrollo del sistema.

![Descripción de la imagen](/doc_img/img1.png "Encabezado")

## Menu Principal

Las opciones disponibles que trendrá seran las siguientes:

![Descripción de la imagen](/doc_img/img2.png "Menu principal")

Para interactuar con el menu principal es necesario utilizar las flechas ubicadas en el NUMPAD y para seleccionar la opcion deseada sera necesario presionar el boton F1

### Iniciar juego

Debido a que es un juego basado en Sokoban, se empleará las mismas mecánicas que el juego antes mencionado. Al inicio de las partidas el jugador comenzara observando que las cajas u objetos a mover se encuentran en una parte y las casillas en donde éstos deberían quedar finalmente en otra.

![Descripción de la imagen](/doc_img/img3.png "Iniciar juego")

El jugador se podrá mover, con las flechas direccionales o los controles que se configuren posteriormente, por todo el nivel. Normalmente, se le presentará al jugador un área delimitada por paredes de la cuál no podrá salir y constituirá el nivel a resolver.

Si ha completado correctamente el nivel, se cargará el siguiente nivel automaticamente.

#### Pausa

Durante una partida, el jugador podrá presionar la tecla F2 para entrar al menú de pausa. En este menú simplemente se dará la opción para continuar o salir hacia el menú principal.

![Descripción de la imagen](/doc_img/img6.png "Pausa")

### Cargar nivel

Para esta parte se le solicitará al usuario el nombre del archivo que contiene el nivel a jugar dentro de la aplicación. Para desarrollar un nivel será necesario utilizar la siguiente sintaxis.

```sh
entidad x, y
```

La entidad puede ser: pared, suelo, jugador, caja y objetivo

La coordenada x puede ser: De 0 hasta 39

La coordenada y puede ser: De 0 hasta 24

Si todo ha salido correctamente, se le mostrará el nivel.
En caso de que haya ocurrido algún error, el sistema te notificará sobre dicho inconveniente.

### Configuracion

Se dará la opción, desde el menú principal a acceder a un menú de configuración. Este menú servirá principalmente para configurar los controles del juego. Para interactuar con las opciones que hay en la configuración es necesario utilizar las flechas ubicadas en el NUMPAD y para seleccionar la opcion deseada sera necesario presionar el boton F1

![Descripción de la imagen](/doc_img/img4.png "Configuracion")

Se le mostrarán los controles actuales y opciones para cambiar controles o regresar al menú principal. Si se decide cambiar, el programa preguntará por la tecla con la que el jugador avanzará en cierta dirección.

![Descripción de la imagen](/doc_img/img5.png "Cambio controles")

### Puntajes altos

El “puntaje” en este caso será la cantidad de movimientos que el jugador emplee para resolver el nivel. Mientras menos puntos tenga más arriba estará en el ranking.

### Salir

Esta opción le permitira finalizar la ejecución del programa
