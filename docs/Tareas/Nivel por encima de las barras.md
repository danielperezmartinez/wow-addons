---
Nombre: Nivel por encima de las barras
Estado: Pendiente
Resumen: En RaidStyleFrames el círculo del nivel (jugador y objetivo) queda por debajo de la barra de poder ampliada. Subirlo de capa o recolocarlo, sin tocar su lógica.
Decisiones: Creada el 2026-11-28 a partir de las capturas del usuario; se hará en otra sesión.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Nivel por encima de las barras

## Objetivo

Que el indicador de nivel (círculo con el número, abajo a la izquierda en el
jugador y abajo a la derecha en el objetivo) se vea entero, por encima de la
barra de poder, en los marcos de
[[Estilo de banda en mascota, objetivo y objetivo del objetivo]].

## Lo que se sabe

- Piezas: en el objetivo, `TargetFrameContent.TargetFrameContentMain.LevelBackgroundCircle`
  (atlas `UI-HUD-UnitFrame-SmallCircle`, visto con `/rsf scan target`) y el texto
  del nivel; en el jugador, las equivalentes de `PlayerFrame`.
- Mismo caso que el nombre del objetivo del objetivo: las barras ampliadas
  quedan en un nivel por encima de esas piezas.

## Opciones (por decidir con el usuario)

1. Subir el círculo y el número a la capa de la barra (como `raiseName`), solo
   fuera de combate.
2. Recolocarlos fuera del recuadro, o dentro de la barra de vida.
3. Ocultarlos (el nivel deja de verse): solo si el usuario lo prefiere.

## Criterios de finalización

- Nivel visible y legible en jugador y objetivo, sin errores en combate.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

## Resultado
