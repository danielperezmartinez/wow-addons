---
Nombre: Retirar ProbeAuras
Estado: Pendiente
Resumen: Cuando ya no haga falta sondear la API, borrar addons/ProbeAuras del repo y pedir al usuario que quite la carpeta de Interface\AddOns en el PC de juego.
Decisiones:
Bloqueada: ["[[Segunda ronda de ProbeAuras]]"]
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Retirar ProbeAuras

## Objetivo

ProbeAuras es una sonda desechable. Cuando ya no se necesite, se retira para que
no siga cargándose ni publicándose en la release.

## Criterios de finalización

- `addons/ProbeAuras/` borrado del repo y sus globales quitados de `.luarc.json`.
- El usuario ha borrado `World of Warcraft\<carpeta>\Interface\AddOns\ProbeAuras`
  (y, si quiere, su SavedVariables).
- La guía [[prueba-probeauras]] se conserva como histórico.

## Verificación

## Resultado
