---
Nombre: Sonda ProbeAuras en Forever (primera ronda)
Estado: Hecha
Resumen: Addon desechable ProbeAuras para medir qué datos de auras y cooldowns son secretos en combate en Forever y qué widgets los aceptan. Hecha el 2026-11-23 en el build 71037; resultados en notas-api-midnight.
Decisiones: Forever carga _Camelot.toc. Las auras quedan bloqueadas del todo en combate para addons; los cooldowns dan isActive/isOnGCD legibles y el tiempo solo vía objeto de duración; C_CooldownViewer no es secreto.
Bloqueada: []
Fecha de creación: 2026-11-22T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Sonda ProbeAuras en Forever (primera ronda)

## Objetivo

Saber, antes de diseñar addons reales, qué devuelve la API de Midnight en Forever
dentro y fuera de combate (auras, cooldowns, gestor de cooldowns), qué campos
llegan como *secret values* y qué setters de widgets los aceptan.

## Criterios de finalización

- El usuario ejecuta la [[prueba-probeauras|guía de prueba]] en Forever.
- Los SavedVariables vuelven a `results/` y los resultados quedan anotados en
  [[notas-api-midnight]].

## Verificación

Prueba hecha por el usuario el 2026-11-23: cliente `1.60.1` build `71037`,
Interface `16001`, paladín en mundo abierto con muñeco. SavedVariables analizados
desde `results/` (no versionado).

## Resultado

Resultados en [[notas-api-midnight#✅ Resultados de ProbeAuras en Forever (2026-11-23)]].
Quedaron sin concluir: `GetPlayerAuraBySpellID` con un aura realmente activa, y
qué exponen los ítems de los marcos del gestor de cooldowns (salieron ocultos).
Siguen en [[Segunda ronda de ProbeAuras]].
