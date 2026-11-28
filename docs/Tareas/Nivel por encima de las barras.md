---
Nombre: Nivel por encima de las barras
Estado: En curso
Resumen: En RaidStyleFrames el círculo del nivel (jugador y objetivo) queda por debajo de la barra de poder ampliada. Subirlo de capa o recolocarlo, sin tocar su lógica.
Decisiones: Creada el 2026-11-28 a partir de las capturas del usuario. El mismo día eligió la opción 1: mismo sitio, por encima de las barras (tapa un poco el maná). Implementado en RaidStyleFrames 0.4.5, pendiente de prueba.
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

## Diseño (0.4.5)

- Las piezas del nivel se localizan por nombre (`Level` en el nombre de
  depuración: círculo, número, calavera de nivel alto…), sin medir nada.
- Fuera de combate se pasan, sin moverlas de sitio, a un marco propio del addon
  hijo del marco de la unidad, con nivel de marco 2 por encima de la barra más
  alta. Así siguen visibles aunque Blizzard oculte la barra de poder (monstruos
  sin maná). Capa `OVERLAY`, el número por encima del círculo.
- Blizzard sigue poniendo el número. En vehículo se devuelven a su padre y capa
  originales.
- `/rsf` añade `level N` a la línea `layout` (piezas encontradas).

## Criterios de finalización

- Nivel visible y legible en jugador y objetivo, sin errores en combate.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

- `luac5.1 -p addons/*/*.lua`: OK (2026-11-28). Simulación local sin errores,
  también con secretos en combate (se aplaza).
- Lista de comprobación de [[normas]]: repasada (2026-11-28).
- Pendiente: CI y prueba en el juego.

## Resultado
