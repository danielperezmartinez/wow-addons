# Normas obligatorias (anti-baneo)

**Se cumplen siempre, sin excepciones.** Si una idea choca con alguna, se descarta o se pregunta antes;
nunca se busca un atajo. Ante la duda, no se hace.

## 1. Política de addons de Blizzard (UI Add-On Development Policy)

Fuente: https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534

1. Gratis: nada de versiones premium, cobro por descarga o por servicios ligados al addon.
2. Código visible: sin ofuscar, legible y accesible públicamente.
3. Sin impacto negativo en reinos u otros jugadores: nada de abusar del chat o de los canales de addon,
   ni de cargar el disco o hundir los FPS.
4. Sin publicidad.
5. Sin pedir donaciones dentro del juego.
6. Sin contenido ofensivo (calificación T).
7. Cumplir los Términos de uso y el EULA de Blizzard.
8. Blizzard puede desactivar cualquier funcionalidad de un addon cuando quiera; se acepta y no se rodea.

## 2. Solo la API del juego

- Solo Lua/XML dentro de `Interface/AddOns`, usando la API que el cliente expone.
- **Prohibido**: lectores o editores de memoria, inyección de código, modificar ficheros del cliente fuera de
  `Interface/AddOns` y `WTF`, interceptar tráfico de red, programas externos que lean la pantalla (píxeles,
  OCR) para reaccionar en el juego, automatización de teclado/ratón (AutoHotkey, macros de periféricos que
  pulsan por ti, bots) y cualquier cosa que juegue por el jugador.
- Ninguna herramienta externa interactúa con el juego en marcha. Los scripts del repo solo crean enlaces y
  copian ficheros de `WTF` con el juego cerrado o tras `/reload`.

## 3. No rodear las restricciones del cliente

- Los *secret values*, las funciones protegidas, el *taint* y el bloqueo en combate son reglas del juego,
  no obstáculos que sortear. Un secreto solo se pasa a las APIs y widgets que lo aceptan oficialmente.
- Prohibido intentar descifrar secretos por vías indirectas (comparar con trucos, medir píxeles o tamaños de
  widgets, deducirlos con tablas de tiempos, etc.) o aprovechar fallos (*exploits*). Si encontramos un fallo,
  no se usa: se anota y, si procede, se informa a Blizzard.
- Los addons **muestran** información; nunca deciden ni ejecutan acciones por el jugador.

## 4. Buen comportamiento

- Nada de spam en chat ni en `SendAddonMessage`; mensajes de addon solo si hacen falta y con límite de envío.
- `OnUpdate` limitado o sustituido por eventos y temporizadores; nada de trabajo pesado por fotograma.
- SavedVariables pequeños; nunca se guardan secretos ni datos de otros jugadores.

## Comprobación antes de cada cambio que llegue al juego

- [ ] Usa solo la API del juego y cumple las 8 reglas de la política.
- [ ] No intenta leer, comparar ni deducir valores secretos fuera de los canales oficiales.
- [ ] No automatiza acciones ni depende de nada externo al juego en marcha.
- [ ] Sin spam de chat o de mensajes de addon y sin trabajo por fotograma innecesario.
- [ ] Código legible, en este repo público.
