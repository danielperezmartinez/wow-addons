---
Nombre: Estilo de banda en mascota, objetivo y objetivo del objetivo
Estado: En curso
Resumen: Llevar el aspecto de recuadro de banda de PlayerClassColor a los marcos de Blizzard de la mascota, el objetivo y el objetivo del objetivo. El juego no lo cubre (comprobado). Diseño aprobado el 2026-11-28: addon renombrado a RaidStyleFrames 0.4.0, implementado y pendiente de prueba en el juego.
Decisiones: 2026-11-28. Renombrar PlayerClassColor a RaidStyleFrames. Mascota en verde. Objetivo y objetivo del objetivo: clase si es jugador, reacción si no, gris si está reservado por otro; si esos datos son secretos, el color de selección oficial pasado tal cual a la barra y, si la barra no lo acepta, verde. El usuario acepta quedarse solo con el recuadro si no hay color.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Estilo de banda en mascota, objetivo y objetivo del objetivo

## Objetivo

Aplicar la fórmula de [[Marco del jugador con color de clase]] (marco de
Blizzard intacto, solo aspecto) a los marcos de la mascota (`PetFrame`), del
objetivo (`TargetFrame`) y del objetivo del objetivo (`TargetFrameToT`).

## ¿Lo cubre el juego?

**No.**

- Internet (2026-11-28): no hay opción nativa de colores de clase para el
  objetivo; hay una sugerencia pendiente en el foro de Blizzard. Lo hacen addons
  de terceros (MUF, MidnightSimpleUnitFrames, Bright UnitFrames) con modos de
  color por clase, reacción o gradiente.
- El usuario (2026-11-28): el Modo edición no tiene opciones de color en esos
  marcos y buscar "color" en Opciones no da nada para ellos.

## Viabilidad (borrador)

- **Mascota**: igual que el jugador. El color es fijo (no depende de nada que
  haya que leer), así que no hay dudas de API. Tiene retrato, vida y poder.
- **Objetivo y objetivo del objetivo**: el color depende del objetivo, que
  cambia en combate. Dudas:
  - Si `UnitClass`, `UnitIsPlayer` y `UnitReaction` del objetivo son
    **secretos en combate** en Forever. Las fuentes discrepan: la Warcraft Wiki
    dice que el primer valor de `UnitClass` es secreto según el caso, y un
    proyecto dice que `UnitReaction` se vuelve secreto en mazmorras. Si lo son,
    el addon no puede decidir el color con ellos ([[normas]], apartado 3).
  - Si alguna API oficial acepta el secreto y devuelve un color que se pueda
    pasar a `SetStatusBarColor` (por ejemplo `C_ClassColor.GetClassColor` o
    `UnitSelectionColor` con secretos). Eso sí sería un canal oficial.
  - Plan B si es secreto: dejar el color de Blizzard en ese caso y aplicar solo
    la forma de recuadro.
- **Lo que no se toca en el objetivo**: sus auras (las dibuja Blizzard, y en
  combate un addon no puede leerlas), la barra de lanzamiento, el icono de
  banda, el indicador de amenaza, el nivel y el dragón de élite o raro.
- La vida y el poder de otros son secretos en combate, pero las barras son de
  Blizzard y los rellena Blizzard: el addon solo cambia textura, color y
  colocación.

## Diseño (aprobado el 2026-11-28)

`addons/PlayerClassColor` pasa a `addons/RaidStyleFrames` (0.4.0). La fórmula
del jugador se generaliza en una definición por marco (`skins`): barras,
nombre, recuadro de referencia, adornos, destello y brillo, con alternativas de
nombre para cada pieza.

| Marco | Recuadro de referencia | Color de vida | Franja de poder |
| --- | --- | --- | --- |
| Jugador | `PlayerFrame.Selection` | Clase | 12 |
| Mascota | `PetFrame.Selection` o el marco | Verde fijo | 6 |
| Objetivo | `TargetFrame.Selection` o el marco | Clase / reacción / gris | 10 |
| Objetivo del objetivo | El propio marco | Clase / reacción / gris | 5 |

- Color del objetivo: `UnitIsTapDenied`, `UnitIsPlayer` + `UnitClass`,
  `UnitReaction` (con `FACTION_BAR_COLORS`), **solo si no son secretos**. Si lo
  son, `UnitSelectionColor` se pasa tal cual a `SetStatusBarColor` dentro de
  `pcall`; si la barra no acepta el secreto, verde. Nunca se compara un
  secreto.
- Poder: color estándar si el tipo no es secreto; si lo es, la barra se deja
  como está.
- Se recolorea en combate al cambiar de objetivo (`PLAYER_TARGET_CHANGED`,
  `UNIT_TARGET`, `UNIT_FACTION`). La colocación, solo fuera de combate.
- Ganchos nuevos: `UnitFrame_Update` (por marco), `TargetFrame:CheckClassification`.
- No se tocan: auras, barra de lanzamiento, nivel, dragón de élite o raro
  (`BossPortraitFrameTexture`), icono de banda, amenaza numérica. Sí se hace
  transparente el fondo de color del nombre del objetivo (`ReputationColor`),
  porque la reacción ya se ve en la barra.
- `/rsf` (y `/pcc`): dos líneas por marco con el origen del color y el estado
  de cada pieza.

## Prueba propuesta

La primera versión del addon trae el diagnóstico en `/pcc`: para cada unidad,
si la clase y la reacción llegan secretas. El usuario lo mira **fuera y dentro
de combate**, en mundo abierto y, si puede, en una mazmorra. Las capturas
deciden el color del objetivo.

## Criterios de finalización

- Los tres marcos con aspecto de recuadro de banda, sin errores en combate.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

- `luac5.1 -p addons/*/*.lua`: OK (2026-11-28).
- Simulación local con un entorno falso de la API (fuera del repo): con todo
  legible y con todo secreto en combate, sin errores de Lua; la colocación se
  aplaza y se aplica al salir de combate.
- Lista de comprobación de [[normas]]: repasada (2026-11-28).
- Pendiente: CI y prueba en el juego.

## Resultado

## Fuentes

- https://us.forums.blizzard.com/en/wow/t/class-color-coding-the-target-frame/1380729
- https://warcraft.wiki.gg/wiki/Secret_Values
- https://github.com/Amadeus-/WoWAddonDevGuide/blob/master/12a_Secret_Safe_APIs.md
- https://www.curseforge.com/wow/addons/muf
- https://www.curseforge.com/wow/addons/bright-unitframes
