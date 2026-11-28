---
Nombre: Medidor de DPS
Estado: Archivada
Resumen: El usuario preguntó por medir el DPS. Se investigaron las opciones y le bastó con conocerlas; no quiso hacer la prueba. El combat log (CLEU) está cerrado para addons, y Forever tendría un medidor nativo, sin confirmar.
Decisiones: Archivada el 2026-11-23 a petición del usuario, sin prueba en el juego.
Bloqueada: []
Fecha de creación: 2026-11-23T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Medidor de DPS

## Objetivo

Saber si un addon propio (o uno existente) puede medir el DPS en Forever.

## Lo investigado (sin probar en el juego)

- `COMBAT_LOG_EVENT_UNFILTERED` ya no llega a los addons en Midnight/Forever.
- Forever tendría un medidor nativo (API `C_DamageMeter`) que leerían ForeverMeter,
  Epic Damage Meter, Rival y Overheat.
- Contradicción: Overheat dice que usa su propio motor de combat log.
- No hay confirmación de que Details funcione en Forever.

## Si se reactiva

Probar con una sonda si existe `C_DamageMeter` y qué devuelve en combate (¿secreto?),
y si CLEU llega de algún modo. Antes, comprobarlo contra [[normas]].

## Criterios de finalización

- Solo si se reactiva.

## Verificación

## Resultado

Archivada sin prueba.
