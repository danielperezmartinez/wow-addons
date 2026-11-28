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
- CI del commit `87f7bcf` (0.4.0): Verificar, Fugas y Publicar en verde;
  `latest` trae `RaidStyleFrames.zip` y ya no `PlayerClassColor.zip`.
- Prueba en el juego del usuario, 0.4.0 (2026-11-28, mundo abierto): colores
  del objetivo correctos, clase (objetivo propio) y reacción (monstruo), también
  en combate, sin secretos. Jugador y objetivo caben en su recuadro del Modo
  edición; el borde de amenaza sale en los dos. El objetivo del objetivo sale
  solo cuando el objetivo tiene objetivo (en combate), con el color de clase
  correcto. El marco de la derecha en el Modo edición es el de **foco**, sin
  estilo. Fallos: el retrato del objetivo sigue visible; las barras de la
  mascota conservan su tamaño original dentro de un recuadro grande; el nombre
  del objetivo del objetivo no se ve.
- 0.4.1: se ocultan las dos piezas candidatas del retrato del objetivo
  (`TargetFrameContainer.Portrait` y `TargetFrame.portrait`), y `/rsf` añade una
  línea `size` por marco (tamaño de barra, relleno y nombre, y si
  `PetFrame.healthbar` es `PetFrameHealthBar`) para diagnosticar la mascota.
- CI del commit `a357b85` (0.4.1): Verificar, Fugas y Publicar en verde.
- Prueba en el juego del usuario, 0.4.1 (2026-11-28, en combate): `/rsf` dio
  un error de Lua: la línea `size` medía el relleno de la barra de vida, cuyo
  ancho es secreto en combate. Fallo del diagnóstico, no del estilo. Medir el
  relleno se acerca a lo que prohíbe [[normas]] (apartado 3), así que se quita,
  no solo se protege. El retrato del objetivo sigue visible (ninguna de las dos
  piezas candidatas es la que se ve) y la mascota sigue con barras pequeñas.
- 0.4.2: `size` solo mide el marco de las barras (protegido con
  `issecretvalue`); nuevo `/rsf scan <marco>` que lista por nombre y atlas las
  texturas y barras visibles de un marco, sin medir nada, para identificar el
  retrato real y las barras de la mascota. Simulación local con todo secreto
  en combate, sin errores.
- CI del commit `5c14b7e` (0.4.2): Verificar, Fugas y Publicar en verde.
- Prueba en el juego del usuario, 0.4.2 (2026-11-28, fuera de combate):
  `/rsf scan target` falló al preguntar si se veía el escudo de la barra de
  lanzamiento (visibilidad secreta), pero antes listó
  `TargetFrameContainer.Portrait` como visible: Blizzard le devuelve la
  opacidad. `/rsf scan pet`: las barras visibles son `PetFrameHealthBar` y
  `PetFrameManaBar`, ya con el tamaño nuevo (108x29 y 108x6), pero sin
  máscaras encontradas: el relleno sigue recortado a la forma antigua.
- 0.4.3: máscaras encontradas preguntando a la textura de relleno de cada barra
  (`GetNumMaskTextures`/`GetMaskTexture`), además de las de nombre conocido;
  adornos vigilados con post-ganchos sobre `SetAlpha`/`Show`/`SetShown`; el
  escaneo salta las piezas con visibilidad secreta y lo indica.
- CI del commit `65f9ffd` (0.4.3): Verificar, Fugas y Publicar en verde.
- Prueba en el juego del usuario, 0.4.3 (2026-11-28, mundo abierto, fuera y
  dentro de combate): "ya parece que se ven bien y no hay errores". Los cuatro
  marcos salen como recuadros de banda; la mascota ya tiene 2 máscaras y barras
  a todo el recuadro; el retrato del objetivo ya no se ve. Detalle pendiente:
  el nombre del objetivo del objetivo no se ve aunque `/rsf` lo da por colocado.
  Sin probar: mazmorra (posibles secretos) y vehículo.
- 0.4.4: el nombre del objetivo del objetivo pertenece al propio marco, un
  nivel por debajo de su barra de vida, y la barra ampliada lo tapa (en los
  demás marcos el nombre está en un marco de contenido por encima de las
  barras). Solo en ese marco (`raiseName`), si el padre del nombre no está por
  encima de la barra, el nombre pasa a ser hijo de la barra con `SetParent`,
  únicamente fuera de combate (en combate se aplaza). Blizzard sigue poniendo el
  texto. Simulación local sin errores.
- Aclaración al usuario: no hay dos marcos de objetivo del objetivo. El que sale
  con aspecto original en el Modo edición es el **marco de foco** (que Blizzard
  muestra siempre en ese modo). El objetivo del objetivo no es un sistema del
  Modo edición: va pegado al marco del objetivo y solo se activa o desactiva
  desde los ajustes de este.

## Resultado

## Fuentes

- https://us.forums.blizzard.com/en/wow/t/class-color-coding-the-target-frame/1380729
- https://warcraft.wiki.gg/wiki/Secret_Values
- https://github.com/Amadeus-/WoWAddonDevGuide/blob/master/12a_Secret_Safe_APIs.md
- https://www.curseforge.com/wow/addons/muf
- https://www.curseforge.com/wow/addons/bright-unitframes
