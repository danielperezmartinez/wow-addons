# Notas: API de Midnight / Forever (estado a 2026-11-22)

Recopilado de Warcraft Wiki y guías de la comunidad **antes** de probar en el juego. Lo marcado ❓ hay que
confirmarlo con ProbeAuras; las fuentes discrepan.

## Forever

- Interface `16001` (`/dump select(4, GetBuildInfo())`). Midnight retail: `120105` (12.1.5); PTR `120107`.
- Sufijos de `.toc`: `_Forever` y `_Camelot` (Forever; Camelot es el nombre interno), `_Standard` (solo
  Midnight, desde 12.1.5), `_Mainline` (familia: Midnight + Forever + Plunderstorm…), `_Classic` (no aplica a
  Forever). Si hay `_Standard` y `_Mainline`, Midnight usa `_Standard`. ❓ prioridad entre `_Forever`,
  `_Camelot` y `_Mainline` en Forever → lo mide `loadedToc`.
- `WOW_PROJECT_ID`: una sonda comunitaria vio `18` (`WOW_PROJECT_CAMELOT`); builds de beta daban `1`. ❓
- Carpeta: las guías dicen `World of Warcraft\_forever_\` con su propio `Interface\AddOns` y `WTF`. ❓ El
  usuario indica que comparte `Interface/AddOns` con retail; lo resolvemos al ver la instalación.
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
