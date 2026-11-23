# wow-addons

Addons propios para **WoW Forever** (cliente moderno, API de Midnight con *secret values*).
Solo API del juego: nada de lectores de memoria ni automatización de entradas.

## Estructura

```
addons/<Addon>/      un addon por carpeta (.toc + .lua), se enlaza tal cual en Interface/AddOns
scripts/link.sh      crea/quita/comprueba los symlinks en Interface/AddOns
scripts/pull-sv.sh   copia los SavedVariables de un addon a results/ para analizarlos
docs/                notas de la API y guías de prueba
```

Addons:

- `ProbeAuras` — sonda **desechable** para ver qué devuelven auras y cooldowns dentro y fuera de combate. Guía: [docs/prueba-probeauras.md](docs/prueba-probeauras.md).

## Enlazar con el juego

1. Crea `.wow-addons-path` en la raíz (no se versiona) con la ruta de `Interface/AddOns`, una por línea
   (puedes poner la de `_retail_` y la de `_forever_` si existen ambas).
2. `scripts/link.sh` (enlaza todos), `scripts/link.sh status`, `scripts/link.sh unlink ProbeAuras`.

Wine/Proton sigue los symlinks de Linux sin problema. Ejecuta los scripts desde el checkout principal.

## .toc

- Interface de Forever: `16001`. Midnight (retail): `120105` (12.1.5). Un mismo `.toc` puede listar varios: `## Interface: 16001, 120105`.
- Sufijos: `_Forever.toc` (alias de `_Camelot.toc`) solo Forever; `_Standard.toc` solo Midnight; `_Mainline.toc` ambos.
  Ver [docs/notas-api-midnight.md](docs/notas-api-midnight.md).

## Editor

VS Code con las extensiones recomendadas (`.vscode/extensions.json`): **WoW API** de Ketho (`ketho.wow-api`, trae
las anotaciones de la API) y Lua de LuaLS. `.luarc.json` fija Lua 5.1 y los globales propios.
Comprobación rápida de sintaxis sin juego: `luac5.1 -p addons/*/*.lua`.
