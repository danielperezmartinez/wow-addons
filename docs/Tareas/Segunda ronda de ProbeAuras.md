---
Nombre: Segunda ronda de ProbeAuras
Estado: Planificando
Resumen: Cerrar lo que la primera ronda dejó sin concluir (búsqueda de aura por spellID con el aura activa, ítems de los marcos del gestor de cooldowns, cargas, encuentros/mazmorra) si algún addon nuevo lo necesita.
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
- `C_Spell.GetSpellCharges` con un hechizo con cargas.
- Comportamiento en mazmorra o encuentro (restricciones más duras).

## Criterios de finalización

- Cada duda anterior queda contestada (o descartada por no hacer falta) en
  [[notas-api-midnight]].

## Verificación

## Resultado
