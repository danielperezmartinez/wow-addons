---
Nombre: Marco del jugador con color de clase
Estado: Planificando
Resumen: Colorear con el color de clase, como en los marcos de banda, la barra de vida del marco del jugador de Blizzard (arriba a la izquierda). El juego no lo cubre (comprobado). Diseño propuesto, el addon PlayerClassColor, pendiente de aprobación.
Decisiones: Alcance elegido el 2026-11-28 (opción a): solo la barra de vida del marco del jugador normal, sin marco propio. Ni el Modo edición ni las Opciones lo cubren.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Marco del jugador con color de clase

## Objetivo

Que la barra de vida del marco del personaje propio (el de Blizzard, arriba a la
izquierda) se vea como en los marcos de grupo con estilo de banda, ya
configurados en [[Colores de clase y maná en marcos de grupo]]: con el color de
la clase. El usuario lo eligió el 2026-11-28 (opción a). No quiere un marco
propio.

## ¿Lo cubre el juego?

**No.** El usuario lo comprobó en Forever el 2026-11-28:

1. `Esc` → **Modo edición** → **marco del jugador**: no hay ningún ajuste de
   color.
2. `Esc` → **Opciones** → **Juego** → **Interfaz**: no hay colores de clase para
   el marco del jugador.

En grupo, los marcos de grupo con estilo de banda ya incluyen al jugador con su
color, pero el usuario quiere el marco normal.

## Diseño propuesto (pendiente de aprobación)

Addon `PlayerClassColor`, pequeño, sin SavedVariables ni opciones:

1. Fuera de combate (al entrar al mundo), lee la clase propia con
   `UnitClass("player")` y su color con `C_ClassColor.GetClassColor`.
2. Busca la barra de vida del marco del jugador (`PlayerFrame_GetHealthBar()` si
   existe; si no, la ruta dentro de `PlayerFrame`).
3. Le pone la textura de relleno de los marcos de banda
   (`Interface\RaidFrame\Raid-Bar-Hp-Fill`) y el color de clase con
   `SetStatusBarColor`. La textura de Blizzard ya es verde, y teñirla daría
   colores sucios: por eso se cambia.
4. Si Blizzard lo restablece (vehículo, cambio de especialización, recarga del
   marco), se vuelve a aplicar con eventos o con `hooksecurefunc`. Nada de
   `OnUpdate`. En vehículo se deja el aspecto de Blizzard.
5. `/pcc` escribe en el chat si encontró la barra y si aplicó el color. Sirve
   para la primera prueba.

**Viabilidad.** No lee ningún dato secreto: la clase propia no lo es y el color
es una constante. Solo llama a métodos de la barra (`SetStatusBarTexture`,
`SetStatusBarColor`) y no escribe campos en los marcos de Blizzard, que es lo
que los ensucia (*taint*). Encaja en [[normas]]: solo cambia el aspecto. Duda
que resuelve la primera prueba: que en combate no salgan errores de Blizzard
(con `/console scriptErrors 1`) y que el color no se pierda.

Descartado: un marco propio con estilo de banda. Es más trabajo, y el usuario
quiere conservar el marco de Blizzard.

## Criterios de finalización

- La barra de vida del marco del jugador sale con el color de clase, también en
  combate, sin errores de Lua.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

## Resultado
