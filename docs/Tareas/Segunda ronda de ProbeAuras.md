---
Nombre: Segunda ronda de ProbeAuras
Estado: Planificando
Resumen: Cerrar lo que la primera ronda dejó sin concluir si algún addon nuevo lo necesita. Pendiente: aura por spellID con el aura activa, auraInstanceID guardado fuera de combate, UNIT_AURA, C_Secrets, ítems del CDM activado, cargas, mazmorra.
Decisiones:
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Segunda ronda de ProbeAuras

## Objetivo

Resolver las dudas abiertas de [[Sonda ProbeAuras en Forever (primera ronda)]]
que afecten a un addon que se quiera hacer. Si ninguna necesidad lo requiere, se
archiva.

Dudas abiertas:

- `C_UnitAuras.GetPlayerAuraBySpellID` / `GetUnitAuraBySpellID` en combate con el
  aura **activa** (en la primera ronda el aura no estaba puesta).
- Marcos del gestor de cooldowns (`EssentialCooldownViewer`…): salieron ocultos;
  repetir con el gestor visible y ver qué devuelven sus ítems.
- `C_UnitAuras.GetUnitAuraInstanceIDs` y `GetAuraDuration` con un
  `auraInstanceID` guardado **fuera** de combate, consultado dentro.
- El *payload* del evento `UNIT_AURA` en combate.
- `C_Secrets.GetSpellAuraSecrecy` / `GetSpellCooldownSecrecy`.
- `C_Spell.GetSpellCharges` con un hechizo con cargas.
- Comportamiento en mazmorra o encuentro (restricciones más duras).

La guía de esta ronda sigue las lecciones de
[[Entorno y flujo de trabajo#Cómo escribir guías de prueba en el juego]]: el CDM
**activado**, el panel de la sonda no es en vivo y el `snap` de dentro se hace
pegando al muñeco.

## Criterios de finalización

- Cada duda anterior queda contestada (o descartada por no hacer falta) en
  [[notas-api-midnight]].

## Verificación

## Resultado
