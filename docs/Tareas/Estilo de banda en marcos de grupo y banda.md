---
Nombre: Estilo de banda en marcos de grupo y banda
Estado: Pendiente
Resumen: Estudiar si conviene llevar la fórmula de RaidStyleFrames (texturas planas, borde de amenaza, nombre, etc.) a los marcos de grupo y de banda de Blizzard. Primero concretar con el usuario qué quiere cambiar, porque esos marcos ya tienen estilo de banda y muchas opciones nativas.
Decisiones: Creada el 2026-11-28 a petición del usuario; se hará en otra sesión.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Estilo de banda en marcos de grupo y banda

## Objetivo

Ver si lo aprendido en [[Marco del jugador con color de clase]] y
[[Estilo de banda en mascota, objetivo y objetivo del objetivo]] se puede aplicar
a los marcos de grupo y de banda (`CompactPartyFrame`, `CompactRaidFrame…`), y
qué aportaría.

## Antes de diseñar

- **Alcance por aclarar con el usuario:** esos marcos ya son recuadros de banda
  y ya muestran colores de clase y maná con las opciones nativas
  ([[Colores de clase y maná en marcos de grupo]]). Hay que saber qué quiere
  que cambie y verlo con capturas.
- **¿Lo cubre el juego? (regla 6):** los perfiles de marcos de banda tienen
  muchas opciones (tamaño, barras de poder, auras, amenaza, mascotas…). Revisar
  primero las opciones y el Modo edición, y buscar en internet.

## Riesgos conocidos

- Son marcos de Blizzard que se actualizan sin parar en combate y manejan
  *secret values*. Un addon conocido (AzeriteUI) provocó errores de secretos en
  `CompactUnitFrame_UpdateHealthColor` al tocarlos (ver las fuentes de
  [[Marco del jugador con color de clase]]).
- Se crean y recolocan dinámicamente (al cambiar el grupo, también en combate):
  la colocación solo se podría tocar fuera de combate.
- Las auras en combate no son legibles para addons ([[notas-api-midnight]]): no
  se puede añadir nada que dependa de ellas.

## Criterios de finalización

- Alcance acordado con el usuario o tarea archivada si las opciones nativas
  bastan.

## Verificación

## Resultado
