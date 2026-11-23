# Prueba en el juego: ProbeAuras

Objetivo: saber qué datos de auras y cooldowns llegan como *secret values* en combate en Forever, y qué
widgets los aceptan. Tarda unos 10 minutos.

## Preparación (una vez)

1. En el PC de Windows, en el clon del repo: `powershell -ExecutionPolicy Bypass -File scripts\link.ps1 ProbeAuras`
   (si WoW no está en `C:\Program Files (x86)\World of Warcraft`, pon antes la ruta de `Interface\AddOns` en
   `.wow-addons-path`). Apunta qué carpetas lista: `_retail_`, `_forever_` o ambas.
   Sin clon: copia `addons\ProbeAuras` tal cual dentro de `Interface\AddOns`.
2. En la pantalla de personajes → **AddOns**: marca *ProbeAuras (test)*. Si sale "desactualizado", marca
   *Cargar addons desactualizados* y apúntalo (significa que el Interface no es ninguno de 16001/120105/120107).
3. Activa el **Gestor de cooldowns** de Blizzard (Opciones → Gameplay/Interfaz → *Cooldown Manager*) y deja
   algunos hechizos en *Esenciales*, *Utilidad* y *Bufos rastreados*.

## Pasos

1. Entra con el personaje. En el chat debe salir:
   `ProbeAuras loaded. interface=… build=… project=… toc=…` → **cópiamelo tal cual**.
2. Fuera de combate, con algún bufo propio activo (p. ej. uno de clase o de comida): `/probe snap fuera`.
   Aparece un recuadro "ProbeAuras widget test" (se puede arrastrar). Fíjate si muestra icono, nombre,
   barras y cooldown.
3. Ve a un **muñeco de entrenamiento**, ponte el bufo y pega 5–10 s, usando 2–3 hechizos con cooldown.
   Al entrar en combate se toma una instantánea sola (`auto-in-combat`). Durante el combate escribe además
   `/probe snap dentro` (mejor con un objetivo con un DoT/debuff tuyo).
   **Mira el recuadro dentro de combate**: ¿se ven icono, nombre, cuenta, barras, espiral de cooldown?
4. Sal de combate (se toma `auto-after-combat` sola).
5. Opcional, si tienes acceso: repítelo en una mazmorra/encuentro (las restricciones son más duras allí).
6. Escribe `/reload` (es lo que guarda los SavedVariables en disco).
7. Si salen errores Lua (ventana de error o `/console scriptErrors 1`), cópialos.

## Devolver los resultados

- `scripts\pull-sv.ps1` copia `ProbeAuras.lua` a `results\` (no se versiona). Pásalo a este PC y déjalo en
  `results/` del repo (o pégame su contenido). Si el script no lo encuentra, el fichero está en
  `World of Warcraft\<_retail_ o _forever_>\WTF\Account\<CUENTA>\SavedVariables\ProbeAuras.lua`.
- Además, en una frase: qué se veía en el recuadro dentro de combate y qué no.

## Qué mide

- `env`: versión, build, Interface, `WOW_PROJECT_ID`, constantes `WOW_PROJECT_*`, **qué .toc cargó**
  (`loadedToc`: base / Forever / Camelot / Mainline / Standard) y qué funciones existen.
- Por instantánea: campos de `C_UnitAuras.GetUnitAuras` (jugador y objetivo) marcados `SECRET:<tipo>` o con
  su valor; qué operaciones Lua fallan con un secreto (comparar, concatenar, aritmética…); duración de auras
  como objeto (`GetAuraDuration`); búsquedas sueltas (`GetPlayerAuraBySpellID`…); categorías e ítems de
  `C_CooldownViewer` y los marcos del gestor (`EssentialCooldownViewer`…); `C_Spell.GetSpellCooldown/Charges`
  de los hechizos del gestor + GCD; y para cada setter de widget (`SetText`, `SetFormattedText`, `SetValue`,
  `SetMinMaxValues`, `SetCooldown*`, `SetTimerDuration`, `SetTexture`, `SetAlphaFromBoolean`, `SetShown`)
  si lo aceptó (`ok`) o dio error.
- No guarda nunca valores secretos, solo descripciones.

Comandos: `/probe snap [etiqueta]`, `/probe add <spellID…>` (hechizos extra), `/probe auto`, `/probe clear`,
`/probe show|hide`.

Cuando acabemos, se desactiva o se borra (`scripts/link.sh unlink ProbeAuras`).
