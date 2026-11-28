---
Nombre: Colores de clase y maná en marcos de grupo
Estado: Planificando
Resumen: El usuario usa marcos de grupo con estilo de banda y salen todos verdes (sin color de clase) y sin la barra de maná de los compañeros. Primero se comprueba si las opciones nativas de marcos de banda lo cubren (regla 6); solo si no, se diseña un addon.
Decisiones: Primera tarea con la regla fundamental 6 (primero, lo que ya hace el juego). Sin diseño de addon hasta tener el resultado de la comprobación en el juego.
Bloqueada: []
Fecha de creación: 2026-11-28T00:00:00+01:00
Última modificación: 2026-11-28T00:00:00+01:00
---

# Colores de clase y maná en marcos de grupo

## Objetivo

En los marcos de grupo con estilo de banda, distinguir la clase de cada
compañero por el color de su barra de vida y ver su barra de maná (o de poder).

## ¿Lo cubre el juego?

Casi seguro que sí. En retail los marcos de banda tienen las opciones "Mostrar
colores de clase" y "Mostrar barras de poder", y el verde uniforme es
justamente lo que se ve con la primera desactivada. Falta confirmar que existen
en Forever y dónde están.

Comprobación pedida al usuario (en curso):

1. `Esc` → **Opciones** → **Juego** → **Interfaz** → apartado **Marcos de
   banda** (o **Marcos de grupo**). Buscar y activar **Mostrar colores de
   clase** y **Mostrar barras de poder** (puede haber también una opción para
   mostrar solo las de los sanadores).
2. Si no aparecen ahí: con un grupo formado, abrir el panel de gestión de banda
   (la pestaña gris del borde izquierdo de la pantalla) → engranaje o
   **Perfiles de banda**. Los ajustes van **por perfil** y el perfil que se usa
   depende del tamaño del grupo: hay que cambiar el que está activo en grupo.
3. Si tampoco: `Esc` → **Modo edición** → clic en los marcos de grupo → ver qué
   ajustes ofrece.
4. Para dejar constancia, en el chat:
   `/dump GetCVar("raidFramesDisplayClassColor"), GetCVar("raidFramesDisplayPowerBars")`
   (solo lee; no cambia nada).

Resultado: _pendiente_.

## Si el juego no lo cubre

Se diseña con el usuario un addon pequeño. Antes de proponer el diseño se
comprueban con una sonda las dudas de la API: si la clase de los compañeros
(`UnitClass`) y su poder (`UnitPower`) son secretos en combate, que no se ha
probado en Forever. También se revisa contra [[normas]]: tocar los marcos de
Blizzard no debe ensuciar (*taint*) sus marcos protegidos.

## Criterios de finalización

- Colores de clase y maná visibles en los marcos de grupo, con las opciones
  nativas (sin addon) o con un addon aprobado y publicado.

## Verificación

## Resultado
