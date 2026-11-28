---
Nombre: Estilo de banda en el marco de foco
Estado: Pendiente
Resumen: Añadir a RaidStyleFrames el marco de foco (FocusFrame) y su objetivo del foco, con el mismo aspecto y colores que el objetivo. Aprovechar la prueba para confirmar el arreglo del nombre del objetivo del objetivo (0.4.4).
Decisiones: Creada el 2026-11-28 a petición del usuario; se hará en otra sesión.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Estilo de banda en el marco de foco

## Objetivo

El marco de foco (clic derecho sobre una unidad → "Establecer foco") sale hoy
con el aspecto original de Blizzard; en el Modo edición se ve siempre, con el
propio jugador de ejemplo. El usuario quiere que se vea como los demás marcos de
[[Estilo de banda en mascota, objetivo y objetivo del objetivo]].

## ¿Lo cubre el juego?

Casi seguro que no: es el mismo caso que el objetivo (sin opción de color ni de
estilo en el Modo edición ni en Opciones, comprobado el 2026-11-28). Al
retomarla, buscar en internet si algún parche lo ha añadido (regla 6).

## Ideas de partida

- `FocusFrame` usa el mismo código que `TargetFrame` (`TargetFrameMixin`): se
  espera la misma estructura (`FocusFrameContainer`, `FocusFrameContent…`,
  `Selection`), así que debería bastar con una definición más en `skins`. Se
  confirma con `/rsf scan focus`.
- Su objetivo del foco (`FocusFrameToT`) es como `TargetFrameToT`.
- Colores: los del objetivo (clase / reacción / gris; verde si son secretos).
- **Pendiente de la tarea anterior:** confirmar que el nombre del objetivo del
  objetivo se ve en combate (`/rsf` debe decir `name ok (moved onto bar)`). Si
  `/rsf` sigue diciendo `name ok` y el nombre no se ve, la causa no era la capa:
  revisar con `/rsf scan tot`.

## Criterios de finalización

- Foco y objetivo del foco como recuadros de banda, sin errores en combate.
- Nombre del objetivo del objetivo confirmado o corregido.
- CI en verde y lista de comprobación de [[normas]] repasada.

## Verificación

## Resultado
