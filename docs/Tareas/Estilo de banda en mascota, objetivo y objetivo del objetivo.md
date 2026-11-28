---
Nombre: Estilo de banda en mascota, objetivo y objetivo del objetivo
Estado: Planificando
Resumen: Llevar el aspecto de recuadro de banda de PlayerClassColor a los marcos de Blizzard de la mascota, el objetivo y el objetivo del objetivo. Pendiente de la comprobación en el Modo edición, de las decisiones de color y de saber si la clase y la reacción del objetivo son secretas en combate en Forever.
Decisiones:
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

Por confirmar en el juego; según internet, no.

- Internet (2026-11-28): no hay opción nativa de colores de clase para el
  objetivo; hay una sugerencia pendiente en el foro de Blizzard. Lo hacen addons
  de terceros (MUF, MidnightSimpleUnitFrames, Bright UnitFrames) con modos de
  color por clase, reacción o gradiente.
- Pendiente: que el usuario mire en el **Modo edición** los ajustes de los
  marcos de objetivo y de mascota.

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

## Prueba propuesta

La primera versión del addon trae el diagnóstico en `/pcc`: para cada unidad,
si la clase y la reacción llegan secretas. El usuario lo mira **fuera y dentro
de combate**, en mundo abierto y, si puede, en una mazmorra. Las capturas
deciden el color del objetivo.

## Criterios de finalización

- Los tres marcos con aspecto de recuadro de banda, sin errores en combate.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

## Resultado

## Fuentes

- https://us.forums.blizzard.com/en/wow/t/class-color-coding-the-target-frame/1380729
- https://warcraft.wiki.gg/wiki/Secret_Values
- https://github.com/Amadeus-/WoWAddonDevGuide/blob/master/12a_Secret_Safe_APIs.md
- https://www.curseforge.com/wow/addons/muf
- https://www.curseforge.com/wow/addons/bright-unitframes
