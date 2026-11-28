---
Nombre: CDMPlus
Estado: Archivada
Resumen: Idea aparcada de ampliar el gestor de cooldowns nativo (CDM) con skin, colocación libre e iconos propios. Se aparcó porque el CDM de Blizzard ya le basta al usuario. Las condiciones sobre la duración de bufos en combate son imposibles.
Decisiones: Aparcada el 2026-11-23 (el CDM nativo basta). Descartado deducir si hay aura enganchando OnShow de los ítems del CDM, porque roza la norma 3.
Bloqueada: []
Fecha de creación: 2026-11-23T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# CDMPlus

## Objetivo

Mejorar el gestor de cooldowns de Blizzard (CDM) sin leer datos secretos. El
usuario no lo conocía; al verlo dijo que hace de WeakAuras y que le basta, así que
la idea queda aparcada hasta que pida algo que el CDM no cubra.

## Ideas viables (según [[notas-api-midnight]])

1. **Skin y colocación libre** sobre los paneles del CDM: adornos como hijos de los
   ítems de Blizzard, para que hereden su visibilidad sin leer ningún dato.
2. **Iconos de cooldown propios**: `C_Spell.GetSpellCooldownDuration(id)` +
   `Cooldown:SetCooldownFromDurationObject` para la espiral, e `isActive` (no
   secreto) para el estado: gris en cooldown y brillo o sonido cuando está listo.

## Imposible o descartado

- Condiciones sobre la duración de bufos en combate: las auras están bloqueadas del
  todo para addons en combate.
- `HookScript("OnShow")` sobre los ítems del CDM para deducir si hay un aura:
  **descartado**, porque es deducir un secreto por una vía indirecta
  ([[normas]], apartado 3).

## Criterios de finalización

- Solo si se reactiva: definir el alcance con el usuario.

## Verificación

## Resultado

Aparcada; no se implementó nada.
