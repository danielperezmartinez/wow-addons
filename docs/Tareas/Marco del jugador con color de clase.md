---
Nombre: Marco del jugador con color de clase
Estado: Planificando
Resumen: El usuario quiere que su propio marco de personaje tenga el mismo estilo que los marcos de grupo de banda (color de clase). Primero se aclara qué quiere exactamente y se comprueba si el juego lo cubre (regla 6); si no, se evalúa un addon.
Decisiones:
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Marco del jugador con color de clase

## Objetivo

Que el marco del personaje propio se vea con el mismo estilo que los marcos de
grupo con estilo de banda, ya configurados en
[[Colores de clase y maná en marcos de grupo]]. Falta concretar qué es "el mismo
estilo": solo el color de clase en la barra de vida del marco del jugador
normal, o un marco con aspecto de banda también en solitario.

## ¿Lo cubre el juego?

Sin comprobar. Lo que se sabe:

- En grupo, los marcos de grupo con estilo de banda ya incluyen al propio
  jugador, con los mismos colores.
- No se conoce una opción nativa de color de clase para el marco del jugador
  normal: hay que mirarlo en Forever.

Comprobación pedida al usuario:

1. `Esc` → **Modo edición** → clic en el **marco del jugador** → mirar qué
   ajustes ofrece (tamaño, estilo, color…).
2. `Esc` → **Opciones** → **Juego** → **Interfaz** (apartado del marco del
   jugador o de nombres/marcos): buscar algo como "colores de clase".
3. En **Modo edición** → marcos de grupo: ver si hay una opción para mostrarlos
   también en solitario o para mostrar al jugador.

Resultado: _pendiente_.

## Si el juego no lo cubre (borrador, sin aprobar)

Hay dos caminos, y ambos tienen dudas que se resolverían con una sonda antes de
diseñar:

- **Colorear la barra de vida del marco de Blizzard**: es el cambio mínimo. El
  riesgo es el *taint*: en Midnight, tocar marcos de Blizzard que manejan
  *secret values* puede romper su propio código en combate. Habría que probar
  que solo cambiar el color de la barra no causa errores.
- **Marco propio con estilo de banda**: no toca a Blizzard. La vida y el poder
  serían secretos en combate, pero `StatusBar` los acepta (probado con
  `SetMinMaxValues`; `SetValue` según la wiki, sin probar). La clase propia
  (`UnitClass("player")`) se puede leer fuera de combate y guardarse. Si es un
  marco de unidad clicable, necesita una plantilla segura (`SecureUnitButtonTemplate`)
  y no se puede cambiar en combate.

En los dos casos se revisa contra [[normas]]: solo se muestra información, y no
se rodea ninguna restricción.

## Criterios de finalización

- El marco del jugador se ve como quiere el usuario, con opciones nativas o con
  un addon aprobado y publicado.

## Verificación

## Resultado
