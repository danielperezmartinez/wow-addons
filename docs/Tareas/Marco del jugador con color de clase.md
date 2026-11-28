---
Nombre: Marco del jugador con estilo de banda
Estado: Planificando
Resumen: El usuario quiere ver su propio marco como un rectángulo de banda (color de clase, barra de maná debajo, perjuicios…), también jugando solo. El juego no lo ofrece; varios addons publicados lo hacen mostrando el marco de grupo de Blizzard en solitario. Diseño propuesto (SoloRaidFrame) pendiente de aprobación.
Decisiones: 2026-11-28: primero se eligió solo colorear la barra de vida (opción a); el usuario lo corrigió: quiere el rectángulo de banda completo con el comportamiento del juego. Se descarta un marco propio: las auras en combate no se pueden leer, así que solo el código de Blizzard puede mostrar los perjuicios.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Marco del jugador con estilo de banda

(El nombre del fichero conserva el título inicial, "con color de clase", para no
romper enlaces.)

## Objetivo

Ver el marco del personaje propio igual que los marcos de grupo con estilo de
banda, ya configurados en [[Colores de clase y maná en marcos de grupo]]: un
rectángulo con el color de clase, la barra de maná debajo, perjuicios, etc., con
el mismo comportamiento que el juego. Tiene que verse también **jugando solo**.

## ¿Lo cubre el juego?

**No.**

- El usuario lo comprobó en Forever el 2026-11-28. Ni el Modo edición ni las
  Opciones tienen colores de clase para el marco del jugador, ni una opción para
  mostrar los marcos de grupo jugando solo.
- Búsqueda en internet (2026-11-28): no hay una opción nativa para ver los
  marcos de grupo con estilo de banda en solitario. Un hilo del foro de
  Blizzard de la beta de Midnight lo confirma, y hay sugerencias pendientes en
  los foros para colorear el marco del jugador.
- Sí hay addons publicados que lo hacen, con versión para Forever:
  BetterRaidFrames, K Solo Raid Frames y la parte SoloFrame de RaidFrameSettings.
  Todos **reutilizan el marco de grupo de Blizzard** (`CompactPartyFrame`), que
  ya incluye al jugador, y lo hacen visible fuera de grupo:
  - RaidFrameSettings: `CompactPartyFrame:SetShown(true)` fuera de combate y un
    gancho sobre `UpdateVisibility`.
  - BetterRaidFrames (el más cuidadoso):
    `RegisterStateDriver(CompactPartyFrame, "visibility", "[group] ignore; show")`,
    `hooksecurefunc` sobre `CompactPartyFrame_Generate` y `UpdateVisibility`,
    sin tocar nada en combate, y comprueba `issecretvalue`.

## Diseño propuesto (pendiente de aprobación)

Addon `SoloRaidFrame`, pequeño, sin SavedVariables:

1. Requisito: "Usar marcos de grupo estilo banda" activado (ya lo está).
2. Fuera de combate, al entrar al mundo y al cambiar el grupo, registra el
   controlador de visibilidad seguro de Blizzard sobre `CompactPartyFrame` con
   `[group] ignore; show`. Jugando solo, el marco de grupo se muestra con un
   único miembro, el jugador. En grupo, decide Blizzard como hasta ahora.
3. Todo lo que se ve lo dibuja el código de Blizzard: color de clase, maná,
   perjuicios, sanación entrante, rango… Funciona igual que en grupo, con las
   mismas opciones que el usuario ya tiene activadas.
4. Nada se toca en combate: si hay que aplicar algo durante el combate, se
   aplaza a `PLAYER_REGEN_ENABLED`. Sin `OnUpdate`.
5. La posición es la de los marcos de grupo en el Modo edición: el usuario los
   coloca arriba a la izquierda.

**Viabilidad y normas.** No lee ningún dato: el addon solo decide cuándo se
muestra un marco de Blizzard, con la API oficial para ello
(`RegisterStateDriver`). Los perjuicios en combate los dibuja Blizzard, que sí
puede leerlos; el addon no los toca. Encaja en [[normas]].

**Riesgos que resuelve la primera prueba:**

- *Taint*: un addon conocido (AzeriteUI) tuvo un error de *secret values* en
  `CompactUnitFrame_UpdateHealthColor` de los marcos de grupo. Hay que probar en
  combate, con `/console scriptErrors 1`, que no salen errores.
- Que en Forever funcione igual que en retail. BetterRaidFrames dice que
  soporta Forever, pero no se ha probado aquí.

**Abierto:** qué hacer con el marco del jugador de Blizzard. Se puede mantener
(en él va también la barra de recursos de clase, como el Poder Sagrado) o
moverlo o ocultarlo con el Modo edición. Lo decide el usuario después de ver la
primera versión.

**Alternativa sin código propio:** instalar BetterRaidFrames o K Solo Raid
Frames. Hacen esto y más, pero son de terceros. Se le ofrece al usuario.

**Descartado:**

- Marco propio desde cero: los perjuicios en combate no se pueden leer desde un
  addon ([[notas-api-midnight]]), así que no podría mostrarlos.
- Solo colorear la barra de vida del marco del jugador: no es lo que quiere el
  usuario.

## Criterios de finalización

- Jugando solo, el marco con estilo de banda del jugador se ve con color de
  clase, maná y perjuicios, también en combate, sin errores de Lua.
- En grupo, los marcos de grupo funcionan como antes.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

## Resultado

## Fuentes

- https://us.forums.blizzard.com/en/wow/t/suggestion-class-colors-for-player-target-and-focus-frame/1402862
- https://eu.forums.blizzard.com/en/wow/t/calling-healers-please-help-with-the-default-party-frames-and-test-it-in-the-game-yourself-in-healers-role-before-it-all-reaches-midnight-release/592434
- https://github.com/casperstorm/BetterRaidFrames/blob/master/SoloFrame.lua
- https://github.com/Slothpala/RaidFrameSettings/blob/master/RaidFrameSettings/Modules/SoloFrame.lua
- https://www.curseforge.com/wow/addons/k-solo-raid-frames
- https://www.curseforge.com/wow/addons/azeriteui-junnez-edition-wow12/files/7863518
