---
Nombre: Marco del jugador con color de clase
Estado: En curso
Resumen: Addon PlayerClassColor. Cambia solo el aspecto del marco del jugador de Blizzard: barra de vida con textura plana de banda y color de clase, y barra de poder con textura plana y su color. Diseño aprobado el 2026-11-28; implementado y pendiente de prueba en el juego.
Decisiones: 2026-11-28. El juego no lo cubre (usuario + internet). Se descartaron el marco de banda en solitario, el cuadro propio y el marco nuevo: el usuario quiere conservar el marco de Blizzard con toda su información y cambiar solo el aspecto. Primera fase, puntos 1 y 2: vida con color de clase y poder con textura plana. Más adelante, opcional: texto de vida más claro y quitar adornos.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Marco del jugador con color de clase

## Objetivo

El usuario interpreta mal a simple vista la vida en el marco del jugador de
Blizzard (arriba a la izquierda). Quiere que se lea como en los marcos de grupo
con estilo de banda ([[Colores de clase y maná en marcos de grupo]]) sin
perder el marco de Blizzard ni nada de lo que muestra (recursos de clase,
vehículo, combate…): **solo un cambio visual**.

## ¿Lo cubre el juego?

**No.**

- Comprobado por el usuario en Forever el 2026-11-28: ni el Modo edición ni las
  Opciones tienen colores de clase para el marco del jugador.
- Búsqueda en internet (2026-11-28): no hay opción nativa; en los foros de
  Blizzard hay sugerencias pendientes. Hay addons que lo hacen (ClassColorFrames,
  HP Bar Class Color, Class Hue, HealthBarColor; Class Hue dice soportar
  Forever).

## Alternativas descartadas (2026-11-28)

- **Mostrar el marco de grupo de Blizzard en solitario**, la técnica de
  BetterRaidFrames, K Solo Raid Frames y RaidFrameSettings
  (`RegisterStateDriver(CompactPartyFrame, "visibility", "[group] ignore; show")`).
  Daba el rectángulo de banda con perjuicios, pero obligaba a tener dos marcos
  o a ocultar el del jugador, y en grupo el cuadro propio no se puede separar
  del bloque: Blizzard lo recoloca, a veces en combate.
- **Cuadro propio con la plantilla de los marcos de banda**: los perjuicios en
  combate quizá no se vean, por el *taint* (ver [[notas-api-midnight]]). Además,
  el usuario quiere el marco de Blizzard.

## Diseño (aprobado el 2026-11-28)

Addon `PlayerClassColor` (`addons/PlayerClassColor/`), sin SavedVariables ni
opciones:

1. Busca las barras de vida y de poder del marco del jugador
   (`PlayerFrame_GetHealthBar` / `PlayerFrame_GetManaBar` o la ruta dentro de
   `PlayerFrame`).
2. Vida: textura `Interface\RaidFrame\Raid-Bar-Hp-Fill` con el color de clase
   (`UnitClass("player")` + `C_ClassColor.GetClassColor`).
3. Poder: textura `Interface\RaidFrame\Raid-Bar-Resource-Fill` con el color
   estándar del tipo de poder (`UnitPowerType` + `PowerBarColor`). Si el tipo
   de poder llegara secreto, no se toca.
4. Se vuelve a aplicar cuando Blizzard restablece su arte: al entrar al mundo,
   `UNIT_DISPLAYPOWER`, `UNIT_EXITED_VEHICLE`, y post-ganchos
   (`hooksecurefunc`) sobre `SetStatusBarTexture`/`SetStatusBarColor` de las dos
   barras, `PlayerFrame_ToPlayerArt`, `PlayerFrame_UpdateArt` y
   `UnitFrameManaBar_UpdateType`. Sin `OnUpdate`. En vehículo se deja el arte de
   Blizzard.
5. `/pcc` escribe un diagnóstico: qué barras encontró, si aplicó el estilo y qué
   ganchos instaló.

Normas: no lee secretos ni escribe campos en los marcos de Blizzard. Solo llama
a métodos de las barras y usa post-ganchos seguros. Es solo aspecto.

## Guía de prueba en el juego

1. Descargar `PlayerClassColor.zip` de la release `latest` y descomprimirlo en
   `World of Warcraft\_forever_\Interface\AddOns\` (debe quedar
   `…\AddOns\PlayerClassColor\PlayerClassColor.toc`).
2. Entrar al juego y escribir `/console scriptErrors 1` para ver los errores de
   Lua.
3. Mirar el marco del jugador: vida con el color de la clase y textura plana,
   maná azul plano.
4. Escribir `/pcc` y copiar las tres líneas que salen.
5. **Mientras se pega a un muñeco** (no antes ni después): ver que el color se
   mantiene al perder y ganar vida y que no sale ninguna ventana de error.
6. Fuera de combate: `/reload` y comprobar que el estilo vuelve.
7. Si es posible, subir y bajar de un vehículo o montura de varios pasajeros.
8. Una frase sobre cómo se ve y si ayuda a leer la vida.

## Criterios de finalización

- Barra de vida con color de clase y barras planas, también en combate, sin
  errores de Lua.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

- `luac5.1 -p addons/*/*.lua`: OK en local (2026-11-28).
- Lista de comprobación de [[normas]]: repasada (2026-11-28). Solo API del
  juego, no lee secretos, no automatiza nada, sin trabajo por fotograma, código
  público.
- CI del commit `d6fef31`: Verificar, Fugas y Publicar en verde; `latest` trae
  `PlayerClassColor.zip` (2026-11-28).
- Prueba en el juego del usuario, fase 1 (2026-11-28): `/pcc` encontró las dos
  barras (`PlayerFrame_GetHealthBar`, `PlayerFrame_GetManaBar`) con el estilo
  aplicado y los cinco ganchos instalados. Vida lisa con color de clase; se
  mantiene en combate y tras `/reload`, sin errores. Vehículo sin probar (no
  tiene montura de pasajeros). El usuario notó que "parte del marco ha
  desaparecido": por aclarar. Valoración: "se ve más limpio, pero aún falta que
  se vea como un recuadro de banda".

## Resultado

## Fuentes

- https://us.forums.blizzard.com/en/wow/t/suggestion-class-colors-for-player-target-and-focus-frame/1402862
- https://www.curseforge.com/wow/addons/class-hue
- https://www.curseforge.com/wow/addons/classcolorframes
- https://github.com/casperstorm/BetterRaidFrames/blob/master/SoloFrame.lua
- https://github.com/Slothpala/RaidFrameSettings/blob/master/RaidFrameSettings/Modules/SoloFrame.lua
- https://www.curseforge.com/wow/addons/azeriteui-junnez-edition-wow12/files/7863518
