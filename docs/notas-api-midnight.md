# Notas: API de Midnight / Forever

## ✅ Resultados de ProbeAuras en Forever (2026-11-23)

Cliente `1.60.1` build `71037` (18-nov-2026), Interface `16001`, `WOW_PROJECT_ID = 18` (`WOW_PROJECT_CAMELOT`;
existen también `WOW_PROJECT_MAINLINE = 1` y `WOW_PROJECT_CLASSIC = 2`). Paladín, mundo abierto, muñeco.

- **TOC**: con base, `_Forever`, `_Camelot`, `_Mainline` y `_Standard` presentes, Forever carga **`_Camelot.toc`**.
  Usar `_Camelot.toc` (o un único `.toc` con `## Interface: 16001`).
- **Auras en combate: bloqueadas del todo** para addons. `C_UnitAuras.GetUnitAuras` y `GetAuraDataByIndex` dan
  error `Auras cannot be accessed when secret while tainted by '<addon>'` (jugador y objetivo). No devuelven
  secretos: no devuelven nada. `GetPlayerAuraBySpellID` / `GetUnitAuraBySpellID` dieron `nil` (sin error), pero
  el hechizo consultado no tenía aura activa: sin concluir.
- **Auras fuera de combate**: todo legible (nombre, spellId, icono, duración…), y todos los widgets las aceptan.
- **Cooldowns en combate** (`C_Spell.GetSpellCooldown`): `startTime`, `duration`, `modRate`, `activeCategory`,
  `timeUntilEndOfStartRecovery` son **secretos**; `isActive`, `isEnabled`, `isOnGCD` **no** lo son.
  `C_Spell.GetSpellTexture` y nombres: no secretos. `GetSpellCharges`: nil (ningún hechizo con cargas).
  El GCD `61304` no existe en Forever.
- **Widgets con secretos (en combate)**: `FontString:SetText(secreto)` ✅, `StatusBar:SetMinMaxValues` ✅,
  `Cooldown:SetCooldownFromDurationObject(C_Spell.GetSpellCooldownDuration(id))` ✅,
  `Region:SetShown(booleano no secreto)` ✅. **`Cooldown:SetCooldown(secreto)` ❌** ("Secret values are only
  allowed during untainted execution").
- **Operaciones Lua sobre un secreto**: concatenar ✅, `string.format("%s")` ✅, `tostring` ✅, `if v` ✅;
  comparar (`==`, `<`) ❌, aritmética ❌, usarlo como clave ❌.
- **Gestor de cooldowns**: `C_CooldownViewer.GetCooldownViewerCategorySet` y `GetCooldownViewerCooldownInfo`
  **no son secretos en combate** (cooldownID, spellID, overrideSpellID, linkedSpellIDs, selfAura, hasAura,
  category…). Categorías: Essential 0, Utility 1, TrackedBuff 2, TrackedBar 3, GroupBuff 4, SpecAgnostic* 5–6,
  EquipSlot* 7–8 (HiddenActive −1 / HiddenPassive −2 no se aceptan). Los marcos `EssentialCooldownViewer`,
  `UtilityCooldownViewer`, `BuffIconCooldownViewer`, `BuffBarCooldownViewer` existen, pero salieron ocultos
  (`IsShown = false`) y los métodos de sus ítems no devolvieron nada: sin concluir.
  Nombres completos de 5–8: SpecAgnosticEssential 5, SpecAgnosticTracked 6, EquipSlotEssential 7,
  EquipSlotTracked 8; −1 y −2 dan error de uso. Los marcos salieron ocultos porque el gestor estaba
  **desactivado** en esa prueba; repetir con él activo.
- **Objetos de duración** (`C_UnitAuras.GetAuraDuration`, `C_Spell.GetSpellCooldownDuration`): userdata con
  `GetRemainingDuration`, `GetTotalDuration`, `GetElapsedDuration` e `IsZero`. En combate,
  `GetRemainingDuration` devuelve un número **secreto** (sirve para pasarlo a widgets, no para decidir nada).
- `C_UnitAuras.GetAuraApplicationDisplayCount` devuelve `""` si el aura no tiene acumulaciones.
- **ID de hechizo**: conviven rangos de estilo clásico (Aura de devoción `10290`, Sentencia `20271`, Bendición de
  protección `1022`) con ID nuevos (Sellos `1323522`, `1324513`…). En el gestor, `linkedSpellIDs` lista todos
  los rangos: al buscar un hechizo, comparar contra toda la lista.
- Cliente en **español (esES)**: los nombres de hechizos y auras llegan en español; identificar siempre por ID.
- **Carpeta de instalación**: `World of Warcraft\_forever_\` con su propio `Interface\AddOns` y `WTF`
  (confirmado por el usuario el 2026-11-28).
- **Marco del jugador** (PlayerClassColor, 2026-11-28): existen `PlayerFrame_GetHealthBar`, `PlayerFrame_GetManaBar`,
  `PlayerFrame_ToPlayerArt`, `PlayerFrame_UpdateArt` y `UnitFrameManaBar_UpdateType`. Cambiar textura y color de esas
  barras (`SetStatusBarTexture`/`SetStatusBarColor`) con post-ganchos `hooksecurefunc` funciona también en combate,
  sin errores de *taint*. `UnitClass("player")` y `C_ClassColor` se leen sin problema.
- **Unidades ajenas** (RaidStyleFrames 0.4.0, 2026-11-28, mundo abierto, en combate contra un monstruo):
  `UnitIsPlayer`, `UnitClass` y `UnitReaction` del objetivo y del objetivo del objetivo **no son secretos**;
  `UnitPowerType` del objetivo tampoco. Sin probar en mazmorra ni en PvP.
- Las barras de `TargetFrame` y `TargetFrameToT` (`.healthbar`/`.manabar`) aceptan textura, color y nueva colocación
  con post-ganchos, sin errores en combate. `TargetFrame.Selection` existe; el marco del objetivo del objetivo no tiene.
- **El tamaño del relleno de una barra con valor secreto es secreto** (`StatusBar:GetStatusBarTexture():GetWidth()` en
  combate: "attempt to perform arithmetic on a secret number value", RaidStyleFrames 0.4.1, 2026-11-28). Medirlo es
  además una vía para deducir el valor: **no se mide** ([[normas]], apartado 3). El tamaño del marco de la barra sí
  se puede leer, pero los diagnósticos lo protegen con `issecretvalue`.
- `C_RestrictedActions` no existe; `C_Secrets.GetSpellAuraSecrecy/GetSpellCooldownSecrecy` sí (sin probar).

---

Lo que sigue es la recopilación previa (2026-11-22); donde choque con lo de arriba, manda lo de arriba.

Recopilado de Warcraft Wiki y guías de la comunidad **antes** de probar en el juego. Lo marcado ❓ hay que
confirmarlo con ProbeAuras; las fuentes discrepan.

## Forever

- Interface `16001` (`/dump select(4, GetBuildInfo())`). Midnight retail: `120105` (12.1.5); PTR `120107`.
- Sufijos de `.toc`: `_Forever` y `_Camelot` (Forever; Camelot es el nombre interno), `_Standard` (solo
  Midnight, desde 12.1.5), `_Mainline` (familia: Midnight + Forever + Plunderstorm…), `_Classic` (no aplica a
  Forever). Si hay `_Standard` y `_Mainline`, Midnight usa `_Standard`. ❓ prioridad entre `_Forever`,
  `_Camelot` y `_Mainline` en Forever → lo mide `loadedToc`.
- `WOW_PROJECT_ID`: una sonda comunitaria vio `18` (`WOW_PROJECT_CAMELOT`); builds de beta daban `1`. ❓
- Carpeta: `World of Warcraft\_forever_\` con su propio `Interface\AddOns` y `WTF` (✅ confirmado, ver arriba).
- Hereda la API y las restricciones de combate de Midnight (secret values).

## Secret values (resumen)

- Comprobación: `issecretvalue(v)`, `canaccessvalue(v)`, `canaccesstable(t)`, `scrubsecretvalues(...)`.
- Con un secreto se puede: guardarlo en variables/tablas, pasarlo a funciones Lua, pasarlo a APIs/widgets
  marcados como aptos, `type()`, `if v then` (salvo booleanos secretos), y según la wiki concatenar y
  `string.format("%s")` ❓.
- Da error: comparar (`== < >`), aritmética, `#`, indexar, usarlo como clave, funciones de `string.*`,
  `tonumber`, test booleano de un booleano secreto.
- SavedVariables no pueden guardar secretos.
- Widgets que los aceptan (wiki): `FontString:SetText/SetFormattedText`, `StatusBar:SetValue/SetMinMaxValues`,
  `StatusBar:SetTimerDuration(durObj)`, `SetAlpha`, `SetAlphaFromBoolean`, `SetShown`, `SetVertexColor`,
  `Cooldown:SetCooldownFromDurationObject(durObj)`. ❓ `SetCooldown`/`SetCooldownFromExpirationTime` (una guía
  dice que desde 12.0.1 solo vale el de objeto de duración). ❓ `Texture:SetTexture` con icono secreto.
- Objetos de duración: `C_UnitAuras.GetAuraDuration(unit, auraInstanceID)` ❓ (nombre),
  `C_Spell.GetSpellCooldownDuration(spellID)`, `C_Spell.GetSpellChargeDuration`, `C_DurationUtil.CreateDuration`.
  Curvas: `C_CurveUtil.CreateCurve/CreateColorCurve` para convertir porcentajes restantes en alfa/color.

## Auras

- `C_UnitAuras.GetUnitAuras(unit, filter)` funciona en combate; el vector no es secreto, los campos sí:
  `name, spellId, icon, duration, expirationTime, applications, sourceUnit…` secretos;
  `auraInstanceID, isHelpful, isHarmful, isFromPlayerOrPlayerPet` no.
- `GetPlayerAuraBySpellID` / `GetAuraDataBySpellName` no funcionan en combate (nil o error) ❓.
- Hay una lista corta de auras/cooldowns nunca secretos (GCD 61304, resurrecciones de combate…).
- Restricción activa en combate, encuentros, M+ y PvP. Los auraInstanceID se re-aleatorizan al empezar
  encuentro/M+/PvP.
- `COMBAT_LOG_EVENT_UNFILTERED` ya no llega a los addons.

## Cooldowns

- `C_Spell.GetSpellCooldown`: `isActive`, `isOnGCD` nunca secretos; `startTime/duration` secretos en combate ❓.
- Gestor de cooldowns (CooldownViewer): `C_CooldownViewer.GetCooldownViewerCategorySet(cat)`,
  `GetCooldownViewerCooldownInfo(cooldownID)`; marcos `EssentialCooldownViewer`, `UtilityCooldownViewer`,
  `BuffIconCooldownViewer`, `BuffBarCooldownViewer`. ❓ qué datos y métodos de sus ítems son legibles.

## Fuentes

- https://warcraft.wiki.gg/wiki/TOC_format
- https://warcraft.wiki.gg/wiki/Secret_Values
- https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes/notes
- https://github.com/Amadeus-/WoWAddonDevGuide/blob/master/12a_Secret_Safe_APIs.md
- https://wowforeverguides.com/addons/developers
- https://endgametools.com/en/wow-forever/news/wow-forever-addons
